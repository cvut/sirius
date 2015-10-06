require 'forwardable'
require 'rspec-parameterized'
require 'spec_helper'
require 'sirius_api/events_authorizer'
require 'sirius_api/user'
require 'sirius_api/scopes'

module SiriusApi
  describe EventsAuthorizer do

    extend Forwardable
    using RSpec::Parameterized::TableSyntax

    subject(:authorizer) { described_class.new(user) }
    def_delegators :authorizer, :authorize_request!


    describe '#authorize_request!' do
      let(:method) { :get }

      shared_examples :authorize_request! do |expected_decision|
        case expected_decision
        when :allow
          it 'allows request' do
            expect { authorize_request! method, url, params }.not_to raise_error
          end
        when :deny
          it 'denies request' do
            expect { authorize_request! method, url, params }.to raise_error(Errors::Authorization)
          end
        end
      end

      where :method, :url                         , :params do
        :get       | '/events'                    | {}
        :get       | '/events/personal'           | {}
        :get       | '/events/:id'                | { id: 123456 }
        :get       | '/rooms/:kos_id/events'      | { kos_id: 'T9:105' }
        :get       | '/courses/:course_id/events' | { course_id: 'BI-DBS' }
      end
      with_them ->{ "#{method.upcase} #{url}" } do
        let(:user) { User.new('rubyeli', scope) }

        [ 'READ_PERSONAL', 'READ_ROLE_BASED', 'READ_ALL' ].each do |scope_name|
          let(:scope) { Scopes.const_get(scope_name) }

          context "for scope #{scope_name}" do
            include_examples :authorize_request!, :allow
          end
        end
      end

      context 'GET /people/:username/events' do

        where :scope_name   , :current_user , :personal, :other_unprivileged, :other_privileged do
          'READ_PERSONAL'   | :any          | :allow   | :deny              | :deny
          'READ_PERSONAL'   | :none         | :deny    | :deny              | :deny
          'READ_ALL'        | :any          | :allow   | :allow             | :allow
          'READ_ALL'        | :none         | :allow   | :allow             | :allow
          'READ_ROLE_BASED' | :unprivileged | :allow   | :deny              | :allow
          'READ_ROLE_BASED' | :privileged   | :allow   | :allow             | :allow
          'READ_ROLE_BASED' | :none         | :deny    | :deny              | :deny
        end
        with_them -> { "for scope #{scope_name} and #{current_user} user" } do

          let(:scope) { Scopes.const_get(scope_name) }
          let(:user) { User.new(current_user == :none ? nil : current_user, scope) }
          let(:url) { '/people/:username/events' }

          cxt = row  # XXX: workaround to make row accessible in nested contexts

          before do
            allow_any_instance_of(User).to receive(:has_any_role?)
              .with(Config.umapi_privileged_roles) do |obj|
                [:privileged, 'bigboss'].include? obj.username
              end
          end

          context 'read personal events' do
            let(:params) { {username: current_user} }
            include_examples :authorize_request!, cxt.personal
          end

          context 'read events of other unprivileged user' do
            let(:params) { {username: 'rubyeli'} }
            include_examples :authorize_request!, cxt.other_unprivileged
          end

          context 'read events of other privileged user' do
            let(:params) { {username: 'bigboss'} }
            include_examples :authorize_request!, cxt.other_privileged
          end
        end
      end
    end
  end
end

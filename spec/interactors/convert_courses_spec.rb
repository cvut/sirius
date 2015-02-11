require 'spec_helper'
require 'interactors/convert_courses'

describe ConvertCourses do

  let(:courses) { [double(link_id: 'BI-ZUM', link_title: 'Sample course')] }

  it 'converts courses' do
    subject.perform(kosapi_courses: courses)
    courses = subject.results[:courses]
    course = courses.first
    expect(course.id).to eq 'BI-ZUM'
    expect(course.name).to eq({'cs' => 'Sample course'})
  end
end

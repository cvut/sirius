module DateRefinements
  refine ::Date do

    # @return [Date] beginning of the week.
    def start_of_week
      self - self.cwday + 1  # cwday starts with 1 (Monday)
    end
  end
end

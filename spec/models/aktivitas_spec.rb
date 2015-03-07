require 'spec_helper'

describe Aktivitas do
  
  describe ".all" do
    subject { Aktivitas.all }
    
    before do
      @corporation = create :wingolf_corporation
      @aktivitas = @corporation.aktivitas
      @other_group = create :group
    end

    it { should include @aktivitas }
    it { should_not include @corporation }
    it { should_not include @other_group }
  end
  
end
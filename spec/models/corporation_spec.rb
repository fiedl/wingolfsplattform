require 'spec_helper'

describe Corporation do
  describe "for an instance of a wingolf corporation" do
    before { @corporation = create :wingolf_corporation }

    describe "#aktivitas" do
      subject { @corporation.aktivitas }

      it { should be_kind_of Aktivitas }
    end
    
    describe "#philisterschaft" do
      subject { @corporation.philisterschaft }
      
      it { should be_kind_of Philisterschaft }
    end
        
  end
end
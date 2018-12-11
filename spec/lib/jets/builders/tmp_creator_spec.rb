describe Jets::Builders::TmpGems do
  context "general" do
    let(:tmp_gems) do
      Jets::Builders::TmpGems.new
    end

    context "within lambda 250MB total limit" do
      it "creates a single layer for gems" do
        opt = File.exist?("#{stage_area}/opt")
        gems = File.exist?("#{stage_area}/gems")
        expect(opt).to be true
        expect(gems).to be false
      end
    end

    context "over lambda 250MB total limit and within limit after lazy loading" do
      it "creates gems.zip to be lazy loaded" do
        opt = File.exist?("#{stage_area}/opt")
        gems = File.exist?("#{stage_area}/gems")
        expect(opt).to be true
        expect(gems).to be true
      end
    end

    context "over lambda 250MB total limit even after lazy loading" do
      it "creates gems.zip to be lazy loaded" do
        opt = File.exist?("#{stage_area}/opt")
        gems = File.exist?("#{stage_area}/gems")
        expect(opt).to be true
        expect(gems).to be true
        tmp_gems.halt # expect this to be called
      end
    end
  end
end

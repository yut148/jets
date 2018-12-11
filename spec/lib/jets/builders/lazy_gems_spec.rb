describe Jets::Builders::LazyGems do
  context "general" do
    let(:lazy_gems) do
      Jets::Builders::LazyGems.new
    end

    context "within lambda 250MB total limit" do
      it "creates a single layer for gems" do
      end
    end

    context "over lambda 250MB total limit" do
      it "creates max size layer for gems" do
      end

      it "creates gems.zip to be lazy loaded" do
      end
    end
  end
end

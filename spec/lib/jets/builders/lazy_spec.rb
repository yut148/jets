describe "Lazy" do
  let(:lazy) { Jets::Builders::Lazy.new }

  context("after project has been built") do
    it "lambdagems" do
      compiled_gems = ["nokogiri-1.8.4", "pg-0.21.0"]
      allow(lazy).to receive(:compiled_gems).and_return(compiled_gems)
      gems = lazy.lambdagems
      expect(gems).to eq compiled_gems
    end
  end
end

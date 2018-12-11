describe Jets::Builders::TmpGems do
  let(:tmp_gems) { Jets::Builders::TmpGems.new }
  let(:build_root) { "tmp/build_root" }
  before(:each) do
    FileUtils.rm_rf(build_root)
    FileUtils.mkdir_p(File.dirname(build_root))
    FileUtils.cp_r("spec/fixtures/build_root", build_root)
    allow(Jets).to receive(:build_root).and_return(build_root)
  end

  context "within lambda 250MB total limit" do
    it "creates a single layer for gems" do
      allow(tmp_gems).to receive(:within_lambda_limit?).and_return(true)

      tmp_gems.create

      vendor_symlink_exists = File.symlink?("#{build_root}/stage/code/vendor/bundle/ruby/2.5.0")
      expect(vendor_symlink_exists).to be true
      opt_is_folder = File.directory?("#{build_root}/stage/opt")
      expect(opt_is_folder).to be true
    end
  end

  # After running spec use tree command to see and debug. You'll see something like this:
  #     $ tree tmp/build_root/
  #     tmp/build_root/
  #     └── stage
  #         ├── code
  #         │   └── vendor
  #         │       └── bundle
  #         │           └── ruby
  #         │               └── 2.5.0 -> /opt/ruby/gems/2.5.0
  #         ├── gems
  #         │   └── 2.5.0
  #         │       ├── bundler
  #         │       ├── gems
  #         │       │   ├── dotenv-2.5.0
  #         │       │   └── rack-2.0.6
  #         │       └── specifications
  #         │           ├── dotenv-2.5.0.gemspec
  #         │           └── rack-2.0.6.gemspec
  #         └── opt
  #             └── ruby
  #                 └── gems
  #                     └── 2.5.0
  #                         ├── bundler -> tmp/build_root/stage/gems/2.5.0/bundler
  #                         ├── gems
  #                         │   ├── dotenv-2.5.0 -> tmp/build_root/stage/gems/2.5.0/gems/dotenv-2.5.0
  #                         │   ├── rack-2.0.6 -> tmp/build_root/stage/gems/2.5.0/gems/rack-2.0.6
  #                         │   └── thor-0.20.3
  #                         └── specifications
  #                             ├── dotenv-2.5.0.gemspec -> tmp/build_root/stage/gems/2.5.0/specifications/dotenv-2.5.0.gemspec
  #                             ├── rack-2.0.6.gemspec -> tmp/build_root/stage/gems/2.5.0/specifications/rack-2.0.6.gemspec
  #                             └── thor-0.20.3.gemspec
  context "over lambda 250MB total limit and within limit after lazy loading" do
    it "creates gems.zip to be lazy loaded" do
      # There's an extra false because within_lambda_limit? is called once outside 
      # before loop inside symlink_tmp_gems.
      allow(tmp_gems).to receive(:within_lambda_limit?).and_return(false, false, false, true)

      tmp_gems.create

      vendor_symlink_exists = File.symlink?("#{build_root}/stage/code/vendor/bundle/ruby/2.5.0")
      expect(vendor_symlink_exists).to be true
      opt_is_folder = File.directory?("#{build_root}/stage/opt")
      expect(opt_is_folder).to be true
      gems_folder_exists = File.directory?("#{build_root}/stage/gems")
      expect(gems_folder_exists).to be true
    end
  end

  context "over lambda 250MB total limit even after lazy loading" do
    it "creates gems.zip to be lazy loaded" do
      allow(tmp_gems).to receive(:within_lambda_limit?).and_return(false) # always returns false

      tmp_gems.create
      
      expect(tmp_gems).to receive(:halt)

      vendor_symlink_exists = File.symlink?("#{build_root}/stage/code/vendor/bundle/ruby/2.5.0")
      expect(vendor_symlink_exists).to be true
      opt_is_folder = File.directory?("#{build_root}/stage/opt")
      expect(opt_is_folder).to be true
      gems_folder_exists = File.directory?("#{build_root}/stage/gems")
      expect(gems_folder_exists).to be true
    end
  end
end

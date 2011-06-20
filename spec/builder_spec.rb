require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Git Payload Builder" do
  before :each do
    @repo = Grit::Repo.new(".")
    @before = "7e32af569ba794b0b1c5e4c38fef1d4e2e56be51"
    @after = "a1a94ba4bfa5f855676066861604b8edae1a20f5"
  end

  it "parses ref name from head" do
    Flowdock::Git::Builder.new(@repo, "refs/heads/master", @before, @after).ref_name.should == "master"
  end

  it "parses ref name from tag" do
    Flowdock::Git::Builder.new(@repo, "refs/tags/release-1.0", @before, @after).ref_name.should == "release-1.0"
  end

  describe "data hash" do
    before :each do
      @repo.stub!(:path).and_return("/foo/bar/flowdock-git-hook/.git")
      @hash = Flowdock::Git::Builder.new(@repo, "refs/heads/master", @before, @after).to_hash
    end

    it "contains before" do
      @hash[:before].should == @before
    end

    it "contains after" do
      @hash[:after].should == @after
    end

    it "contains ref" do
      @hash[:ref].should == "refs/heads/master"
    end

    it "contains ref name" do
      @hash[:ref_name].should == "master"
    end

    describe "commits" do
      it "contains all changed commits" do
        @hash[:commits].should have(2).items
      end

      it "has commit author information" do
        @hash[:commits].first[:author][:name].should == "Ville Lautanala"
        @hash[:commits].first[:author][:email].should == "lautis@gmail.com"
      end

      it "has commit id" do
        @hash[:commits].first[:id].should == "cf4a78c59cf9e06ebd7336900b2a66b85a88b76c"
      end

      it "puts deleted files in an array" do
        @hash[:commits].first[:removed].should include("spec/flowdock-git-hook_spec.rb")
      end

      it "puts added files to an array" do
        @hash[:commits].first[:added].should include("lib/flowdock/git.rb")
      end

      it "detects modified files" do
        @hash[:commits].first[:modified].should_not include("spec/flowdock-git-hook_spec.rb")
        @hash[:commits].first[:modified].should_not include("lib/flowdock/git.rb")
        @hash[:commits].first[:modified].should include("lib/flowdock-git-hook.rb")
      end
    end

    describe "repository information" do
      it "contains repository name based on file path" do
        @hash[:repository][:name] = "flowdock-git-hook"
      end
    end
  end
end
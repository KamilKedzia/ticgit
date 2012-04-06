require File.dirname(__FILE__) + "/spec_helper"

describe TicGitNG do
  include TicGitNGSpecHelper

  before(:all) do
    @path = setup_new_git_repo
    @orig_test_opts = test_opts
    @ticgitng = TicGitNG.open(@path, @orig_test_opts)
  end

  after(:all) do
    Dir.glob(File.expand_path("~/.ticgit-ng/-tmp*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
    Dir.glob(File.expand_path("~/.ticgit/-tmp*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
    Dir.glob(File.expand_path("/tmp/ticgit-ng-*")).each {|file_name| FileUtils.rm_r(file_name, {:force=>true,:secure=>true}) }
  end

  it "Should only create a new branch when 'ti init' is called" do
    git_dir_2=        setup_new_git_repo
    git_opts_2=       test_opts
    git_opts_2[:init]=false

    #With :init set to false, the default when calling ti
    lambda { ticgitng_2=TicGitNG.open(git_dir_2, git_opts_2) }.should raise_error SystemExit

    #with :init set to true, the default for TicGitNGSpecHelper.test_opts(), the branch should be created without error
    lambda { ticgitng=TicGitNG.open( @path, @orig_test_opts )}.should_not raise_error SystemExit

  end

  it "should create a new branch if it's not there" do
    br = @ticgitng.git.branches.map { |b| b.name }
    br.should include('ticgit')
  end

  it "should find an existing ticgit-ng branch if it's there" do
    tg = TicGitNG.open(@path, test_opts)
    @ticgitng.git.branches.size.should eql(tg.git.branches.size)
  end

  it "should find the .git directory if it's there" do
    @ticgitng.git.dir.path.should eql(@path)
  end

  it "should look for the .git directory until it finds it" do
    tg = TicGitNG.open(File.join(@path, 'subdir'), @orig_test_opts)
    tg.git.dir.path.should eql(@path)
  end

  it "should add a .hold file to a new branch" do
    @ticgitng.in_branch{ File.file?('.hold').should == true }
  end

end

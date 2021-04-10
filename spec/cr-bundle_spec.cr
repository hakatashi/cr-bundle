require "./spec_helper"
require "file_utils"

describe CrBundle do
  describe "bundler" do
    it %[require "./file" and expand "./file.cr"] do
      File.write("file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "./file"\nputs "a.cr"])
      run_bundle("a.cr").should eq <<-RESULT
      # require "./file"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm(%w[a.cr file.cr])
    end
    it %[require "./file.cr" and expand "./file.cr"] do
      File.write("file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "./file.cr"\nputs "a.cr"])
      run_bundle("a.cr").should eq <<-RESULT
      # require "./file.cr"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm(%w[a.cr file.cr])
    end
    it %[require "./file" and expand "./file/file.cr"] do
      Dir.mkdir("file")
      File.write("file/file.cr", %[puts "file/file.cr"])
      File.write("a.cr", %[require "./file"\nputs "a.cr"])
      run_bundle("a.cr").should eq <<-RESULT
      # require "./file"
      puts "file/file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm_r("file")
      FileUtils.rm("a.cr")
    end
    it %[require "../file" and expand "../file.cr"] do
      Dir.mkdir("dir")
      File.write("file.cr", %[puts "file.cr"])
      File.write("dir/a.cr", %[require "../file"\nputs "dir/a.cr"])
      run_bundle("dir/a.cr").should eq <<-RESULT
      # require "../file"
      puts "file.cr"
      puts "dir/a.cr"
      RESULT
      FileUtils.rm_r("dir")
      FileUtils.rm("file.cr")
    end
    it %[require "../file.cr" and expand "../file.cr"] do
      Dir.mkdir("dir")
      File.write("file.cr", %[puts "file.cr"])
      File.write("dir/a.cr", %[require "../file.cr"\nputs "dir/a.cr"])
      run_bundle("dir/a.cr").should eq <<-RESULT
      # require "../file.cr"
      puts "file.cr"
      puts "dir/a.cr"
      RESULT
      FileUtils.rm_r("dir")
      FileUtils.rm("file.cr")
    end
    it %[require "../file" and expand "../file/file.cr"] do
      Dir.mkdir("file")
      File.write("file/file.cr", %[puts "file/file.cr"])
      Dir.mkdir("dir")
      File.write("dir/a.cr", %[require "../file"\nputs "dir/a.cr"])
      run_bundle("dir/a.cr").should eq <<-RESULT
      # require "../file"
      puts "file/file.cr"
      puts "dir/a.cr"
      RESULT
      FileUtils.rm_r(%w[file dir])
    end

    it %[require "file.cr" and expand "file.cr"] do
      Dir.mkdir("dir")
      File.write("dir/file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "file.cr"\nputs "a.cr"])
      run_bundle("a.cr", %w[dir]).should eq <<-RESULT
      # require "file.cr"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm("a.cr")
      FileUtils.rm_r("dir")
    end
    it %[require "file" and expand "file.cr"] do
      Dir.mkdir("dir") unless Dir.exists?("dir")
      File.write("dir/file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "file"\nputs "a.cr"])
      run_bundle("a.cr", %w[dir]).should eq <<-RESULT
      # require "file"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm("a.cr")
      FileUtils.rm_r("dir")
    end
    it %[require "file" and expand "file/file.cr"] do
      Dir.mkdir_p("dir/file")
      File.write("dir/file/file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "file"\nputs "a.cr"])
      run_bundle("a.cr", %w[dir]).should eq <<-RESULT
      # require "file"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm("a.cr")
      FileUtils.rm_r("dir")
    end
    it %[require "file" and expand "file/src/file.cr"] do
      Dir.mkdir_p("dir/file/src")
      File.write("dir/file/src/file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "file"\nputs "a.cr"])
      run_bundle("a.cr", %w[dir]).should eq <<-RESULT
      # require "file"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm("a.cr")
      FileUtils.rm_r("dir")
    end
    it %[require "file" and expand "file/src/file/file.cr"] do
      Dir.mkdir_p("dir/file/src/file")
      File.write("dir/file/src/file/file.cr", %[puts "file.cr"])
      File.write("a.cr", %[require "file"\nputs "a.cr"])
      run_bundle("a.cr", %w[dir]).should eq <<-RESULT
      # require "file"
      puts "file.cr"
      puts "a.cr"
      RESULT
      FileUtils.rm("a.cr")
      FileUtils.rm_r("dir")
    end

    it "require same file" do
      File.write("a.cr", %[puts "a.cr"])
      File.write("b1.cr", %[require "./a"\nputs "b1.cr"])
      File.write("b2.cr", %[require "./a"\nputs "b2.cr"])
      File.write("c.cr", %[require "./b1"\nrequire "./b2"\nputs "c.cr"])
      run_bundle("c.cr").should eq <<-RESULT
      # require "./b1"
      # require "./a"
      puts "a.cr"
      puts "b1.cr"
      # require "./b2"
      
      puts "b2.cr"
      puts "c.cr"
      RESULT
      FileUtils.rm(%w[a.cr b1.cr b2.cr c.cr])
    end
    it "require each other" do
      File.write("a.cr", %[require "./b"\nputs "a"])
      File.write("b.cr", %[require "./a"\nputs "b"])
      run_bundle("a.cr").should eq <<-RESULT
      # require "./b"

      puts "b"
      puts "a"
      RESULT
      FileUtils.rm(%w[a.cr b.cr])
    end
  end
end

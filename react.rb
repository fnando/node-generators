#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "thor"
end

require "thor"
require "thor/group"

class ReactGenerator < Thor::Group
  include Thor::Actions
  desc "Generate a new filesystem structure"

  def project_name
    File.basename(destination_root)
  end

  def self.source_root
    File.join(__dir__, "templates")
  end

  def generate_project
    run "npx create-react-app #{project_name} --typescript"
  end

  def install_dependencies
    packages = [
      "@fnando/codestyle",
      "@fnando/eslint-config-codestyle",
      "@fnando/npm-scripts",
      "@types/jest",
      "@typescript-eslint/eslint-plugin",
      "@typescript-eslint/parser",
      "eslint-config-prettier",
      "eslint-plugin-prettier",
      "eslint-plugin-react",
      "eslint-plugin-react-hooks",
      "husky",
      "jest",
      "jest-filename-transform",
      "lint-staged",
      "prettier",
      "ts-jest"
    ]

    inside(destination_root) do
      run "yarn add -D #{packages.join(' ')}"
    end
  end

  def node_version
    @node_version ||= `node --version`.chomp[1..-1]
  end

  def copy_files
    remove_file "tsconfig.json"
    remove_file "jest.config.js"

    copy_file ".prettierrc.js"
    copy_file "react/.eslintrc.js", ".eslintrc.js"
    copy_file "react/jest.config.js", "jest.config.js"
    copy_file "react/tsconfig.json", "tsconfig.json"
    template ".tool-versions.erb", ".tool-versions"
  end

  def commit_files
    inside(destination_root) do
      run "rm -rf .git"
      run "git init"
      run "git add ."
      run "git commit -m 'Initial commit.'"
    end
  end
end

generator = ReactGenerator.new
generator.destination_root = File.expand_path(ARGV.first)
generator.invoke_all

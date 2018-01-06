require "codestatus/version"
require "codestatus/build_status"
require "codestatus/cli"
require "codestatus/package_resolvers/base"
require "codestatus/package_resolvers/rubygems_resolver"
require "codestatus/package_resolvers/npm_resolver"
require "codestatus/package_resolvers/repository_not_found_error"
require "codestatus/package_resolvers/resolver_not_found_error"
require "codestatus/package_resolvers/package_not_found_error"
require "codestatus/repositories/base"
require "codestatus/repositories/github_repository"
require "codestatus/repositories/bitbucket_repository"

module Codestatus
  def self.status(repository: nil, registry: nil, package: nil)
    if !repository && registry && package
      begin
        repository = resolver(registry).resolve!(package)
      rescue PackageResolvers::ResolverNotFoundError
        abort "#{package}: Resolver for `#{registry}` not found"
      rescue PackageResolvers::PackageNotFoundError
        abort "#{package}: Package not found"
      rescue PackageResolvers::RepositoryNotFoundError
        abort "#{package}: Repository not found"
      end
    end

    if repository
      repository.status
    else
      BuildStatus.new(sha: nil, status: nil)
    end
  end

  def self.resolver(registry)
    resolver = resolvers.detect { |resolver| resolver.match?(registry) }
    raise PackageResolvers::ResolverNotFoundError unless resolver
    resolver
  end

  def self.resolvers
    @resolvers ||= [
      PackageResolvers::RubygemsResolver,
      PackageResolvers::NpmResolver,
    ]
  end
end

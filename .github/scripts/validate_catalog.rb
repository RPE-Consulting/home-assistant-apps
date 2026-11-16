#!/usr/bin/env ruby
# frozen_string_literal: true

# Valide chaque `<dossier>/config.yaml` du catalogue :
#   - YAML valide ;
#   - clés `name`, `version`, `slug`, `arch` et `image` présentes et non vides ;
#   - `slug` identique au nom du dossier.
# Ruby et sa bibliothèque standard suffisent : aucune dépendance à installer.
#
# Usage : validate_catalog.rb [racine du catalogue]

require "yaml"

REQUIRED_KEYS = %w[name version slug arch image].freeze

def blank?(value)
  value.nil? || (value.respond_to?(:empty?) && value.empty?) || value.to_s.strip.empty?
end

def check(path)
  folder = File.basename(File.dirname(path))

  begin
    config = YAML.safe_load(File.read(path))
  rescue Psych::Exception => e
    return ["YAML invalide : #{e.message}"]
  end
  return ["le document doit être un dictionnaire YAML"] unless config.is_a?(Hash)

  errors = REQUIRED_KEYS.select { |key| blank?(config[key]) }
                        .map { |key| "clé `#{key}` absente ou vide" }

  arch = config["arch"]
  if !blank?(arch) && !(arch.is_a?(Array) && arch.all? { |a| a.is_a?(String) && !a.strip.empty? })
    errors << "`arch` doit être une liste d'architectures"
  end

  slug = config["slug"]
  if !blank?(slug) && slug.to_s != folder
    errors << "`slug` (#{slug}) différent du nom du dossier (#{folder})"
  end

  errors
end

root = ARGV[0] || "."
paths = Dir.glob(File.join(root, "*", "config.yaml")).sort

if paths.empty?
  puts "Aucune app dans le catalogue : rien à valider."
  exit 0
end

failed = false
paths.each do |path|
  shown = path.sub(%r{\A\./}, "")
  errors = check(path)
  if errors.empty?
    puts "ok    #{shown}"
  else
    failed = true
    errors.each do |error|
      puts "ERREUR #{shown} : #{error}"
      puts "::error file=#{shown}::#{error}" if ENV["GITHUB_ACTIONS"]
    end
  end
end

exit(failed ? 1 : 0)

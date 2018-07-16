module FixtureHelper

  def self.get_fixture_file(fixture_name)
    @@dir = File.join(Dir.pwd, 'spec', 'fixtures')
    File.new(File.join(@@dir, fixture_name))
  end

end
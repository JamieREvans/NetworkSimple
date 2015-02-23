Pod::Spec.new do |s|
  s.name             = "NetworkSimple"
  s.version          = "1.0.2"
  s.summary          = "Simplifying all network requests"
  s.description      = <<-DESC
                       Sacrifice control for a whole new level of simplicity. All of your network requests with just one method.
                       DESC
  s.homepage         = "https://github.com/JamieREvans/NetworkSimple"
  s.license          = 'MIT'
  s.author           = { "Jamie Evans" => "jamie.riley.evans@gmail.com" }
  s.source           = { :git => "https://github.com/JamieREvans/NetworkSimple.git", :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.dependency 'NSJSONSerialization-NSNullRemoval', '~> 1.0'
  s.dependency 'Reachability', '~> 3.2'

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'NetworkSimple' => ['Pod/Assets/*.png']
  }
	
end

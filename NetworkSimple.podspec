Pod::Spec.new do |s|
  s.name             = "NetworkSimple"
  s.version          = "1.0.1"
  s.summary          = "Simplifying all network requests"
  s.description      = <<-DESC
                       Are you tired of writing long-winded network requests?
											 If you said yes to the previous question, then do we
											 have a tool for you.
											 Introducing NetworkSimple. It's simple, clean, fast and best
											 of all, it's free!
											 Order now and we'll throw in a kitten.
											 ***Kitten may or may not be included.***
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

Pod::Spec.new do |spec|
spec.name = "TerceptSDK@rodalsoft"
spec.version = "0.0.1"
spec.summary = "TerceptSDK@rodalsoft Library to Test"
spec.description = "It is a library only for testing TerceptSDK@rodalsoft"
spec.homepage = "https://github.com/techsamuelsani/TerceptSDK-rodalsoft"
spec.license = { :type => "MIT", :file => "LICENSE" }
spec.author = { "Rodal Soft" => "rodalsoft@gmail.com" }
spec.platform = :ios, "11.0"
spec.swift_version = '5.0'
spec.source = { :git => "https://github.com/techsamuelsani/TerceptSDK-rodalsoft.git", :tag => '0.0.1' }
spec.source_files = "TerceptSDK/**/*.{swift}"
end
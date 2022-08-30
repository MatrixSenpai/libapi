Pod::Spec.new do |spec|
    spec.name          = 'LibAPI'
    spec.version       = '1.0.3'
    spec.license       = { :type => 'GPLv3', :file => 'License.md' }
    spec.homepage      = 'https://github.com/MatrixSenpai/libapi.git'
    spec.authors       = { 'Mason Phillips' => 'math.matrix@icloud.com' }
    spec.summary       = 'A base package for writing simple HTTP REST-compatible libraries'
    spec.source        = { :git => 'https://github.com/MatrixSenpai/libapi.git', :tag => spec.version.to_s }
    spec.module_name   = 'libapi'
    spec.swift_version = '5.3'

    spec.ios.deployment_target     = '14.0'
    spec.osx.deployment_target     = '11.0'
    spec.watchos.deployment_target = '6.0'

    spec.default_subspecs = 'Core', 'LibAPI+RxSwift'

    spec.subspec 'Core' do |sub|
        sub.source_files = 'Sources/libapi/**/*.swift'
        sub.exclude_files = 'Sources/libapi+rxswift/**'
    end

    spec.subspec 'LibAPI+RxSwift' do |sub|
        sub.dependency 'LibAPI/Core', spec.version.to_s
        sub.dependency 'RxSwift', '~> 6.5.0'
        
        sub.source_files = 'Sources/libapi+rxswift/**/*.swift'
        sub.exclude_files = 'Sources/libapi/**'
    end
end

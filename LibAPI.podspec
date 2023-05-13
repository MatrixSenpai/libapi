Pod::Spec.new do |spec|
    spec.name          = 'LibAPI'
    spec.version       = '2.0.0'
    spec.license       = { :type => 'GPLv3', :file => 'LICENSE.md' }
    spec.homepage      = 'https://github.com/MatrixSenpai/libapi'
    spec.authors       = { 'Mason Phillips' => 'math.matrix@icloud.com' }
    spec.summary       = 'A base package for writing simple HTTP REST-compatible libraries'
    spec.source        = { :git => 'https://github.com/MatrixSenpai/libapi.git', :tag => spec.version.to_s }
    spec.module_name   = 'LibAPI'
    spec.swift_version = '5.3'

    spec.ios.deployment_target     = '16.0'
    spec.osx.deployment_target     = '13.0'
    spec.watchos.deployment_target = '9.0'

    spec.default_subspecs = 'Core'
    spec.requires_arc     = false

    spec.subspec 'Core' do |sub|
        sub.source_files = 'Sources/LibAPI/**/*.swift'
        sub.exclude_files = 'Sources/LibAPI+Combine/**', 'Sources/LibAPI+RxSwift/**'
    end

    spec.subspec 'LibAPI+Combine' do |sub|
        sub.dependency 'LibAPI/Core', spec.version.to_s

        sub.source_files = 'Sources/LibAPI+Combine/API+Combine.swift'
    end

    spec.subspec 'LibAPI+RxSwift' do |sub|
        sub.dependency 'LibAPI/Core', spec.version.to_s
        sub.dependency 'RxSwift', '~> 6.5.0'

        sub.source_files = 'Sources/LibAPI+RxSwift/API+RxSwift.swift'
    end
end

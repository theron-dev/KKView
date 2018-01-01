
Pod::Spec.new do |s|


  s.name         = "KKView"
  s.version      = "1.0.2"
  s.summary      = "XML/JS 原生渲染"
  s.description  = "XML/JS 原生渲染, 支持双向数据绑定"

  s.homepage     = "https://github.com/hailongz/KKView"
  s.license      = "MIT"
  s.author       = { "zhang hailong" => "hailongz@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/hailongz/KKView.git", :tag => "#{s.version}" }

  s.vendored_frameworks = 'KKView.framework'
  s.requires_arc = true
  s.dependency 'KKObserver', '~> 1.0.2' 
  s.dependency 'KKHttp', '~> 1.0.1' 

end

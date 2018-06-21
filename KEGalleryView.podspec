Pod::Spec.new do |s|


  s.name         = "KEGalleryView"
  s.version      = "0.1"
  s.summary      = "轮播图"
  s.description  = <<-DESC

        实用的轮播图
                   DESC
  s.homepage     = "https://github.com/yanglukai/KEGalleryView"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author       = { "yanglukai" => "530607291@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/yanglukai/KEGalleryView.git", :tag => s.version }
  s.source_files = "KEGalleryView/**/*.{h,m}"
  s.requires_arc = true


end

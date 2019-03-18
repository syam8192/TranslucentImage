//
//  AppDelegate.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2019/03/18.
//  Copyright © 2019年 山上 忍. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var displaySize: NSRect? = nil
    var pitchX: CGFloat = 0.0;
    var imageView: NSImageView? = nil
    
    var viewWidth: CGFloat = 320
    var viewHeight: CGFloat = 320
    
    var image: NSImage? = nil
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var imagePosition = 0
    
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        initializeWindow()
        imagePosition = 0
    }
    
    // アプリ終了時の処理
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // 初期化
    func initializeWindow()
    {
        
        //　・画面のサイズを取得する
        // visibleFrame = 1326, 745
        displaySize = NSScreen.main?.visibleFrame
        // frame = 1366, 768
        displaySize = NSScreen.main?.frame
        Swift.print(String(format: "displaySize %4.0lf %4.0lf", displaySize!.width, displaySize!.height))
        
        //　・Windowのタイトルバーを非表示にする
        // Windowのタイトルバーを非表示にする（xibで設定する）
        //        window.titleVisibility = NSWindowTitleVisibility.Hidden
        
        //　・透明なウィンドウを作成する（Windowの背景を透過する）
        // Window背景を透過するおまじない
        window.isOpaque = false
        // Window背景を透過する
        window.backgroundColor = NSColor.clear
        
        //　・透明なウィンドウを前面に配置（スクリーンセーバーと同じ Zオーダーに描画する）
        // Window Layers and Levels
        // Z orderを Screen Saverと同じにする
//        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.screenSaverWindow)))
        
        //　・描画内容全体を半透明化する
        // タイトルバーを含む全体を半透明
        window.alphaValue = CGFloat(0.7)
        
        //　・透明なウィンドウでクリック等の UI操作を無効にする（マウス操作を無効化）
        // マウス操作を無効（表示するだけで UI操作を妨害しない）
//        window.ignoresMouseEvents = true
        
        //        // マウス操作で動かせる様にする
        window.isMovableByWindowBackground = true
        
        //　・リソースに定義した画像を NSImageに読み込む
        // アニメーションの連結画像をリソースから読み込む
        // http://www.neko.ne.jp/~freewing/tmp/MacGoGoDance.png
        // 2500 * 228 px
        // ImageCatの名前でリソースに画像を定義しておく
        image = NSImage(named: "ImageCat")
        
        // 読み込んだ画像のサイズ（NSImageの sizeは dpに依存する）
        //        let imageSize = (image?.size)!
        
        // 読み込んだ画像サイズ NSBitmapImageRepの sizeは dpに依存しないので安全）
        let bitmapImageRef = NSBitmapImageRep(data:image!.tiffRepresentation!)!
        let imageSize = (bitmapImageRef.size)
        Swift.print(String(format: "imageSize %4.0lf %4.0lf", imageSize.width, imageSize.height))
        
        // １画像あたりのサイズを代入
        imageWidth = imageSize.width
        imageHeight = imageSize.height
        
        let scale: CGFloat = 3.2
        viewWidth = imageWidth * scale
        viewHeight = imageHeight * scale
        
        viewWidth = 320
        viewHeight = 320

        
        // NSImageViewを指定のサイズで生成
//        imageView = NSImageView(frame: NSMakeRect(0.0, 0.0, viewWidth, viewHeight))
        
        //　・画像をアスペクト比を保持して拡大縮小して表示する
        // アスペクト比を保持して拡大縮小
//        imageView?.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        
        // Windowsのサイズを画像と同じ大きさにする
        window.setContentSize(NSSize(width: viewWidth, height: viewHeight))
        
        //        // ウインドウをスクリーンの中心に配置
        //        window.center()
        
        // ウインドウをスクリーンの下端に配置
        window.setFrameOrigin(CGPoint(x: 0, y: 0))
        
        // NSImageViewを Windowに追加
//        window.contentView!.addSubview(imageView!)
        
        //　・Windowを最前面に表示
        // 前面に表示
        window.orderFront(self)
        // 表示
        window.makeKeyAndOrderFront(self)
        
        // 動かすドット数 X軸
        pitchX = CGFloat(floatLiteral: Double(displaySize!.width + imageWidth) / 256.0)
        if (pitchX < 1.0) {
            pitchX = 1.0
        }
    }
    
    
    // 画像更新メソッド
    @objc func updateImageView()
    {
        // 表示画像を更新
        displayImage(position: imagePosition)
        
        
        
        // 画像の表示位置を徐々に移動する
        var x = imageView!.frame.origin.x
        x -= CGFloat(pitchX)
        if (x >= displaySize!.width) {
            x = -viewWidth
        }
        else
            if (x < -viewWidth) {
                x = displaySize!.width - CGFloat(pitchX)
        }
        imageView!.frame.origin.x = x
    }
    
    
    func displayImage(position: Int)
    {
        //　・画像の一部分を切り出して指定範囲に描画する
        // 切り出す画像の範囲を設定
        let rect: CGRect = CGRect(x: CGFloat(position) * imageWidth, y: 0, width: imageWidth, height: imageHeight)

        
        //　・NSImageを CGImageに変換する
        // NSImageを CGImageに変換する
        let cgImage = image!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        // CGImageの指定範囲を取り出す
        let imageRef: CGImage = cgImage.cropping(to: rect)!
//            CGImageCreateWithImageInRect(cgImage, rect)!
        
        // boundsは既に Viewの初期化の時に設定してあるので不要
        //        imageView!.bounds = rect
        
        // NSImageViewに画像をセットして表示
        imageView!.image = NSImage(cgImage: imageRef, size: CGSize(width: imageWidth, height: imageHeight))
    }

}


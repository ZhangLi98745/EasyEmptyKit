EasyEmptyKit
=======
> A lightweight, swift library for displaying emptyView whenever the tableView has no content to display

[![Swift Version][swift-image]][swift-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)


## 要求

* iOS8.0+
* Xcode 8.0+

## 安装
1. 下载并且将EasyEmptyKit文件夹拖拽至你的工程
2. 恭喜！

## 用法

### 设置代理

```swift
class SomeViewController: UITableViewController { 

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.emptyDelegate = self
    }
}
```

### 实现代理协议

```swift
extension SomeViewController : EasyEmptyKitProtocol {
    func emptyTableViewData() -> EasyEmptyKitModel? {
        return EasyEmptyKitModel(title: "title",
                                 imageName: "imageName",
                                 buttonTitle: "buttonTitle",
                                 buttonColor: UIColor.blue,
                                 emptyButtonPress: { (button) in
            // do some thing

        })
    }    
}
```

### 刷新布局
> 第一次创建tableView时，默认不显示占位图，再一次刷新tableView时，在没有数据的情况下，占位图出现

```swift
self.tableView.reloadData()
```

</span>

[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/

### License

EasyEmptyKit is licensed under the MIT License, please see the LICENSE file.




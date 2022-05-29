

import UIKit


public class ImageProvider {

    public static func image(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: self), compatibleWith: nil)
    }
}

public class BundleProvider {
    // convenient for specific image
    public static var bundle: Bundle {
        return Bundle(for: self)
    }
}





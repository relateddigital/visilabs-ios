
import UIKit

public class CountdownTimerBannerModel: TargetingActionViewModel {
    public var targetingActionType: TargetingActionType = .CountdownTimerBanner
    
    public var jsContent: String?
    public var jsonContent: String?
    
    public var actId: Int = 0
    public var auth: String = ""
    public var hasMailForm: Bool = false
    public var waitingTime: Int = 0
    
    public var report: CountdownTimerReport?
    
    // Parser mappings (public to allow assignment from VisilabsTargetingAction)
    public var scratch_color: String?
    public var ios_lnk: String?
    public var img: String?
    public var content_body: String?
    public var counter_Date: String?
    public var counter_Time: String?
    public var background_color: String?
    public var counter_color: String?
    public var close_button_color: String?
    public var content_body_text_color: String?
    public var position_on_page: String?
    public var content_body_font_family: String?
    public var txtStartDate: String?
    
    // Standard getters for View (public)
    public var title: String?
    public var message: String? { return content_body }
    public var position: String { return position_on_page ?? "bottom" }
    public var background: String? { return background_color }
    public var closeButtonColor: String? { return close_button_color }
    public var textColor: String? { return content_body_text_color }
    
    // Timer specific
    public var scratchColor: String? { return scratch_color }
    public var counterColor: String? { return counter_color }
    
    public var iconUrl: String? { return img }
    
    public var targetDate: Date? {
        return nil 
    }
    
    public init(targetingActionType: TargetingActionType = .CountdownTimerBanner) {
        self.targetingActionType = targetingActionType
    }
}

public struct CountdownTimerReport: Codable {
    public var impression: String?
    public var click: String?
    
    public init(impression: String?, click: String?) {
        self.impression = impression
        self.click = click
    }
}

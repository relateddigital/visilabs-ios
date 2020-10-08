//
//  VisilabsStory.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

//{"capping":"{\"data\":{}}","VERSION":2,"FavoriteAttributeAction":[],"Story":[{"actid":250,"title":"storytestnative","actiontype":"Story","actiondata":{"stories":[{"title":"test1","smallImg":"https://cdn.jpegmini.com/user/images/slider_puffin_jpegmini_mobile.jpg","link":"https://visilabs.com?OM.zn=acttype-32&OM.zpc=act-250"},{"title":"test2","smallImg":"https://cdn.jpegmini.com/user/images/slider_puffin_jpegmini_mobile.jpg","link":"https://visilabs.com?OM.zn=acttype-32&OM.zpc=act-250"},{"title":"test3","smallImg":"https://cdn.dsmcdn.com/marketing/datascience/automation/2020/9/7/FirsatUrunuMainBadge_202009071848.png","link":"https://visilabs.com?OM.zn=acttype-32&OM.zpc=act-250"}],"taTemplate":"story_looking_banners","ExtendedProps":"%7B%22storylb_img_borderWidth%22%3A%223%22%2C%22storylb_img_borderColor%22%3A%22%23cc3a3a%22%2C%22storylb_img_borderRadius%22%3A%2210%25%22%2C%22storylb_img_boxShadow%22%3A%22rgba(0%2C0%2C0%2C0.4)%205px%205px%2010px%22%2C%22storylb_label_color%22%3A%22%23a83c3c%22%7D"}}]}

// https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&OM.exVisitorID=ogun.ozturk%40euromsg.com&action_type=Story&OM.apiver=IOS

class VisilabsStory {
    internal init(title: String? = nil, smallImg: String? = nil, link: String? = nil, snaps: [VisilabsSnap]? = nil) {
        self.title = title
        self.smallImg = smallImg
        self.link = link
        if let snaps = snaps {
            self._snaps = snaps
        } else {
            self._snaps = [VisilabsSnap]()
        }
        self.internalIdentifier = ""
        self.lastUpdated = 0
    }
    
    let title: String?
    let smallImg: String?
    let link: String?
    
    
    public var snapsCount: Int {
        return snaps.count
    }
    
    // To hold the json snaps.
    private var _snaps: [VisilabsSnap]
    
    // To carry forwarding non-deleted snaps.
    public var snaps: [VisilabsSnap] {
        return _snaps.filter{!($0.isDeleted)}
    }
    //TODO: bu nasıl set edilecek düşün
    public var internalIdentifier: String
    public var lastUpdated: Int
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    enum CodingKeys: String, CodingKey {
        //case snapsCount = "snaps_count"
        case _snaps = "snaps"
        case internalIdentifier = "id"
        case lastUpdated = "last_updated"
        case title = "title"
        case smallImg = "smallImg"
        case link = "link"
    }
}

extension VisilabsStory: Equatable {
    public static func == (lhs: VisilabsStory, rhs: VisilabsStory) -> Bool {
        return lhs.internalIdentifier == rhs.internalIdentifier
    }
}

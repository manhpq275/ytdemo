//
//  YTResponse.swift
//  canvasee_ios
//
//  Created by Cu Rua Vui Tinh on 10/08/2022.
//  Copyright © 2022 Canvasee Vietnam. All rights reserved.
//

import Foundation

// MARK: - Response
struct YTResponse: Codable {
    var contents: Contents?

    func getContinueItem() -> ContinuationItemRenderer? {
        
        guard let contents = getContents() else {
            return nil
        }
        for contentItem in contents {
            guard let continuteItem = contentItem.continuationItemRenderer else {
                continue
            }
            return continuteItem
        }
        return nil
    }
    private func getContents() -> [RichGridRendererContent]? {
        return self.contents?.twoColumnBrowseResultsRenderer?.tabs?.first?.tabRenderer?.content?.richGridRenderer?.contents
    }
    func getVideos(shareUrl: String) -> [VideoModel] {
        var resultList: [VideoModel] = []
        guard let contents = getContents() else {
            return resultList
        }
        
        for content in contents {
            guard let video = content.richItemRenderer?.content?.videoRenderer else {
                continue
            }
            var result = VideoModel()
            let channelObject = video.ownerText?.runs?.first
            let channelId = channelObject?.navigationEndpoint?.browseEndpoint?.browseID
            let channelName = channelObject?.text
            let channelAvatar = video.channelThumbnailSupportedRenderers?.channelThumbnailWithLinkRenderer?.thumbnail?.thumbnails?.first?.url
            result.channelID = channelId
            result.channelImage = channelAvatar
            result.channelName = channelName
            
            result.expanded = false
            result.time = video.getVideoTime()
            result.id = -1
            result.shareUrl = shareUrl.appending(video.videoID ?? "")

            result.publishedVideoAt = video.publishedTimeText?.simpleText
            result.thumbnail = video.thumbnail?.thumbnails?.last?.url
            result.title = video.title?.runs?.first?.text
            result.videoID = video.videoID
            result.views = video.viewCountText?.simpleText
            resultList.append(result)
        }
        return resultList
    }
    
    // MARK: - Contents
    struct Contents: Codable {
        var twoColumnBrowseResultsRenderer: TwoColumnBrowseResultsRenderer?
        var twoColumnWatchNextResults: TwoColumnWatchNextResults?
    }
    
    struct TwoColumnWatchNextResults: Codable {
        var secondaryResults: TwoColumnWatchNextResultsSecondaryResults?
    }
    
    struct TwoColumnWatchNextResultsSecondaryResults: Codable {
        var secondaryResults: SecondaryResults?
    }
    
    struct SecondaryResults: Codable {
        var results: [RichItemRendererContent]?
    }
    
    struct ItemSectionRenderer: Codable  {
        var contents: [SectionRenderer]?
    }
    
    struct SectionRenderer: Codable  {
        var compactVideoRenderer: VideoRenderer?

    }
    
    
    // MARK: - TwoColumnBrowseResultsRenderer
    struct TwoColumnBrowseResultsRenderer: Codable {
        var tabs: [Tab]?
    }
    
    // MARK: - Tab
    struct Tab: Codable {
        var tabRenderer: TabRenderer?
    }
    
    // MARK: - TabRenderer
    struct TabRenderer: Codable {
        var selected: Bool?
        var content: TabRendererContent?
        var tabIdentifier, trackingParams: String?
    }
    
    // MARK: - TabRendererContent
    struct TabRendererContent: Codable {
        var richGridRenderer: RichGridRenderer?
    }
    
    // MARK: - RichGridRenderer
    struct RichGridRenderer: Codable {
        var contents: [RichGridRendererContent]?
        var trackingParams: String?
        var header: RichGridRendererHeader?
        var targetID: String?
        var reflowOptions: ReflowOptions?
        
        enum CodingKeys: String, CodingKey {
            case contents, trackingParams, header
            case targetID = "targetId"
            case reflowOptions
        }
    }
    
    // MARK: - RichGridRendererContent
    struct RichGridRendererContent: Codable {
        var richItemRenderer: RichItemRenderer?
        var continuationItemRenderer: ContinuationItemRenderer?
    }
    
    // MARK: - ContinuationItemRenderer
    struct ContinuationItemRenderer: Codable {
        var trigger: String?
        var continuationEndpoint: ContinuationEndpoint?
        var ghostCards: GhostCards?
    }
    
    // MARK: - ContinuationEndpoint
    struct ContinuationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var continuationCommand: ContinuationEndpointContinuationCommand?
    }
    
    // MARK: - ContinuationEndpointCommandMetadata
    struct ContinuationEndpointCommandMetadata: Codable {
        var webCommandMetadata: PurpleWebCommandMetadata?
    }
    
    // MARK: - PurpleWebCommandMetadata
    struct PurpleWebCommandMetadata: Codable {
        var sendPost: Bool?
        var apiURL: String?
        
        enum CodingKeys: String, CodingKey {
            case sendPost
            case apiURL = "apiUrl"
        }
    }
    
    // MARK: - ContinuationEndpointContinuationCommand
    struct ContinuationEndpointContinuationCommand: Codable {
        var token: String?
        var request: String?
    }
    
    // MARK: - GhostCards
    struct GhostCards: Codable {
        var ghostGridRenderer: GhostGridRenderer?
    }
    
    // MARK: - GhostGridRenderer
    struct GhostGridRenderer: Codable {
        var rows: Int?
    }
    
    // MARK: - RichItemRenderer
    struct RichItemRenderer: Codable {
        var content: RichItemRendererContent?
        var trackingParams: String?
    }
    
    // MARK: - RichItemRendererContent
    struct RichItemRendererContent: Codable {
        var videoRenderer: VideoRenderer?
        var compactVideoRenderer: VideoRenderer?
        var itemSectionRenderer: ItemSectionRenderer?
    }
    
    // MARK: - VideoRenderer
    struct VideoRenderer: Codable {
        var videoID: String?
        var thumbnail: ChannelThumbnailWithLinkRendererThumbnail?
        var title: PurpleTitle?
        var descriptionSnippet: TextClass?
        var longBylineText: LongBylineTextClass?
        var publishedTimeText: PublishedTimeTextClass?
        var lengthText: LengthTextClass?
        var viewCountText: PublishedTimeTextClass?
        var navigationEndpoint: VideoRendererNavigationEndpoint?
        var ownerText, shortBylineText: LongBylineTextClass?
        var trackingParams: String?
        var showActionMenu: Bool?
        var shortViewCountText: LengthTextClass?
        var menu: Menu?
        var channelThumbnailSupportedRenderers: ChannelThumbnailSupportedRenderers?
        var thumbnailOverlays: [ThumbnailOverlay]?
        var inlinePlaybackEndpoint: InlinePlaybackEndpoint?
        var ownerBadges: [OwnerBadge]?
        
        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case thumbnail, title, descriptionSnippet, longBylineText, publishedTimeText, lengthText, viewCountText, navigationEndpoint, ownerText, shortBylineText, trackingParams, showActionMenu, shortViewCountText, menu, channelThumbnailSupportedRenderers, thumbnailOverlays, inlinePlaybackEndpoint, ownerBadges
        }
        
        func getVideoTime() -> Int {
            var time = self.lengthText?.simpleText?.getTimeByText() ?? 0
            if (time == 0) {
                time = self.thumbnailOverlays?.first?.thumbnailOverlayTimeStatusRenderer?.text?.simpleText?.getTimeByText() ?? 0
            }
            return time
        }
    }
    
    // MARK: - ChannelThumbnailSupportedRenderers
    struct ChannelThumbnailSupportedRenderers: Codable {
        var channelThumbnailWithLinkRenderer: ChannelThumbnailWithLinkRenderer?
    }
    
    // MARK: - ChannelThumbnailWithLinkRenderer
    struct ChannelThumbnailWithLinkRenderer: Codable {
        var thumbnail: ChannelThumbnailWithLinkRendererThumbnail?
        var navigationEndpoint: ChannelThumbnailWithLinkRendererNavigationEndpoint?
        var accessibility: AccessibilityData?
    }
    
    // MARK: - AccessibilityData
    struct AccessibilityData: Codable {
        var accessibilityData: Accessibility?
    }
    
    // MARK: - Accessibility
    struct Accessibility: Codable {
        var label: String?
    }
    
    // MARK: - ChannelThumbnailWithLinkRendererNavigationEndpoint
    struct ChannelThumbnailWithLinkRendererNavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var browseEndpoint: NavigationEndpointBrowseEndpoint?
    }
    
    // MARK: - NavigationEndpointBrowseEndpoint
    struct NavigationEndpointBrowseEndpoint: Codable {
        var browseID, canonicalBaseURL: String?
        
        enum CodingKeys: String, CodingKey {
            case browseID = "browseId"
            case canonicalBaseURL = "canonicalBaseUrl"
        }
    }
    
    // MARK: - InlinePlaybackEndpointCommandMetadata
    struct InlinePlaybackEndpointCommandMetadata: Codable {
        var webCommandMetadata: FluffyWebCommandMetadata?
    }
    
    // MARK: - FluffyWebCommandMetadata
    struct FluffyWebCommandMetadata: Codable {
        var url: String?
        var webPageType: String?
        var rootVe: Int?
        var apiURL: String?
        
        enum CodingKeys: String, CodingKey {
            case url, webPageType, rootVe
            case apiURL = "apiUrl"
        }
    }
    
    // MARK: - ChannelThumbnailWithLinkRendererThumbnail
    struct ChannelThumbnailWithLinkRendererThumbnail: Codable {
        var thumbnails: [ThumbnailElement]?
    }
    
    // MARK: - ThumbnailElement
    struct ThumbnailElement: Codable {
        var url: String?
        var width, height: Int?
    }
    
    // MARK: - TextClass
    struct TextClass: Codable {
        var runs: [TitleRun]?
    }
    
    // MARK: - TitleRun
    struct TitleRun: Codable {
        var text: String?
    }
    
    // MARK: - InlinePlaybackEndpoint
    struct InlinePlaybackEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var watchEndpoint: InlinePlaybackEndpointWatchEndpoint?
    }
    
    // MARK: - InlinePlaybackEndpointWatchEndpoint
    struct InlinePlaybackEndpointWatchEndpoint: Codable {
        var videoID: String?
        var playerParams: String?
        var playerExtraURLParams: [Param]?
        var watchEndpointSupportedOnesieConfig: WatchEndpointSupportedOnesieConfig?
        
        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case playerParams
            case playerExtraURLParams = "playerExtraUrlParams"
            case watchEndpointSupportedOnesieConfig
        }
    }
    
    // MARK: - Param
    struct Param: Codable {
        var key, value: String?
    }
    
    
    // MARK: - WatchEndpointSupportedOnesieConfig
    struct WatchEndpointSupportedOnesieConfig: Codable {
        var html5PlaybackOnesieConfig: Html5PlaybackOnesieConfig?
    }
    
    // MARK: - Html5PlaybackOnesieConfig
    struct Html5PlaybackOnesieConfig: Codable {
        var commonConfig: CommonConfig?
    }
    
    // MARK: - CommonConfig
    struct CommonConfig: Codable {
        var url: String?
    }
    
    // MARK: - LengthTextClass
    struct LengthTextClass: Codable {
        var accessibility: AccessibilityData?
        var simpleText: String?
    }
    
    // MARK: - LongBylineTextClass
    struct LongBylineTextClass: Codable {
        var runs: [LongBylineTextRun]?
    }
    
    // MARK: - LongBylineTextRun
    struct LongBylineTextRun: Codable {
        var text: String?
        var navigationEndpoint: ChannelThumbnailWithLinkRendererNavigationEndpoint?
    }
    
    // MARK: - Menu
    struct Menu: Codable {
        var menuRenderer: MenuRenderer?
    }
    
    // MARK: - MenuRenderer
    struct MenuRenderer: Codable {
        var items: [ItemElement]?
        var trackingParams: String?
        var accessibility: AccessibilityData?
        var targetID: String?
        
        enum CodingKeys: String, CodingKey {
            case items, trackingParams, accessibility
            case targetID = "targetId"
        }
    }
    
    // MARK: - ItemElement
    struct ItemElement: Codable {
        var menuServiceItemRenderer: MenuServiceItemRenderer?
    }
    
    // MARK: - MenuServiceItemRenderer
    struct MenuServiceItemRenderer: Codable {
        var text: TextClass?
        var icon: IconImage?
        var serviceEndpoint: MenuServiceItemRendererServiceEndpoint?
        var trackingParams: String?
        var hasSeparator: Bool?
    }
    
    // MARK: - IconImage
    struct IconImage: Codable {
        var iconType: String?
    }
    
    // MARK: - MenuServiceItemRendererServiceEndpoint
    struct MenuServiceItemRendererServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var signalServiceEndpoint: UntoggledServiceEndpointSignalServiceEndpoint?
        var playlistEditEndpoint: ServiceEndpointPlaylistEditEndpoint?
        var addToPlaylistServiceEndpoint: AddToPlaylistServiceEndpoint?
        var shareEntityServiceEndpoint: ShareEntityServiceEndpoint?
        var feedbackEndpoint: FeedbackEndpoint?
        var getReportFormEndpoint: GetReportFormEndpoint?
    }
    
    // MARK: - AddToPlaylistServiceEndpoint
    struct AddToPlaylistServiceEndpoint: Codable {
        var videoID: String?
        
        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
        }
    }
    
    // MARK: - FeedbackEndpoint
    struct FeedbackEndpoint: Codable {
        var feedbackToken: String?
        var uiActions: UIActions?
        var actions: [FeedbackEndpointAction]?
    }
    
    // MARK: - FeedbackEndpointAction
    struct FeedbackEndpointAction: Codable {
        var clickTrackingParams: String?
        var replaceEnclosingAction: ReplaceEnclosingAction?
    }
    
    // MARK: - ReplaceEnclosingAction
    struct ReplaceEnclosingAction: Codable {
        var item: ReplaceEnclosingActionItem?
    }
    
    // MARK: - ReplaceEnclosingActionItem
    struct ReplaceEnclosingActionItem: Codable {
        var notificationMultiActionRenderer: NotificationMultiActionRenderer?
    }
    
    // MARK: - NotificationMultiActionRenderer
    struct NotificationMultiActionRenderer: Codable {
        var responseText: ResponseText?
        var buttons: [Button]?
        var trackingParams: String?
        var dismissalViewStyle: String?
    }
    
    // MARK: - Button
    struct Button: Codable {
        var buttonRenderer: ButtonButtonRenderer?
    }
    
    // MARK: - ButtonButtonRenderer
    struct ButtonButtonRenderer: Codable {
        var style: String?
        var text: ButtonRendererText?
        var serviceEndpoint: PurpleServiceEndpoint?
        var trackingParams: String?
        var command: PurpleCommand?
    }
    
    // MARK: - PurpleCommand
    struct PurpleCommand: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var urlEndpoint: URLEndpoint?
    }
    
    // MARK: - URLEndpoint
    struct URLEndpoint: Codable {
        var url: String?
        var target: String?
    }
    
    // MARK: - PurpleServiceEndpoint
    struct PurpleServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var undoFeedbackEndpoint: UndoFeedbackEndpoint?
        var signalServiceEndpoint: CommandSignalServiceEndpoint?
    }
    
    // MARK: - CommandSignalServiceEndpoint
    struct CommandSignalServiceEndpoint: Codable {
        var signal: String?
        var actions: [PurpleAction]?
    }
    
    // MARK: - PurpleAction
    struct PurpleAction: Codable {
        var clickTrackingParams: String?
        var signalAction: Signal?
    }
    
    // MARK: - Signal
    struct Signal: Codable {
        var signal: String?
    }
    
    
    // MARK: - UndoFeedbackEndpoint
    struct UndoFeedbackEndpoint: Codable {
        var undoToken: String?
        var actions: [UndoFeedbackEndpointAction]?
    }
    
    // MARK: - UndoFeedbackEndpointAction
    struct UndoFeedbackEndpointAction: Codable {
        var clickTrackingParams: String?
        var undoFeedbackAction: UploadEndpoint?
    }
    
    // MARK: - UploadEndpoint
    struct UploadEndpoint: Codable {
        var hack: Bool?
    }
    
    // MARK: - ButtonRendererText
    struct ButtonRendererText: Codable {
        var simpleText: String?
        var runs: [TitleRun]?
    }
    
    // MARK: - ResponseText
    struct ResponseText: Codable {
        var accessibility: AccessibilityData?
        var simpleText: String?
        var runs: [TitleRun]?
    }
    
    // MARK: - UIActions
    struct UIActions: Codable {
        var hideEnclosingContainer: Bool?
    }
    
    // MARK: - GetReportFormEndpoint
    struct GetReportFormEndpoint: Codable {
        var params: String?
    }
    
    // MARK: - ServiceEndpointPlaylistEditEndpoint
    struct ServiceEndpointPlaylistEditEndpoint: Codable {
        var playlistID: String?
        var actions: [FluffyAction]?
        
        enum CodingKeys: String, CodingKey {
            case playlistID = "playlistId"
            case actions
        }
    }
    
    // MARK: - FluffyAction
    struct FluffyAction: Codable {
        var addedVideoID: String?
        var action: String?
        
        enum CodingKeys: String, CodingKey {
            case addedVideoID = "addedVideoId"
            case action
        }
    }
    
    // MARK: - ShareEntityServiceEndpoint
    struct ShareEntityServiceEndpoint: Codable {
        var serializedShareEntity: String?
        var commands: [CommandElement]?
    }
    
    // MARK: - CommandElement
    struct CommandElement: Codable {
        var clickTrackingParams: String?
        var openPopupAction: CommandOpenPopupAction?
    }
    
    // MARK: - CommandOpenPopupAction
    struct CommandOpenPopupAction: Codable {
        var popup: PurplePopup?
        var popupType: String?
        var beReused: Bool?
    }
    
    // MARK: - PurplePopup
    struct PurplePopup: Codable {
        var unifiedSharePanelRenderer: UnifiedSharePanelRenderer?
    }
    
    // MARK: - UnifiedSharePanelRenderer
    struct UnifiedSharePanelRenderer: Codable {
        var trackingParams: String?
        var showLoadingSpinner: Bool?
    }
    
    // MARK: - UntoggledServiceEndpointSignalServiceEndpoint
    struct UntoggledServiceEndpointSignalServiceEndpoint: Codable {
        var signal: String?
        var actions: [TentacledAction]?
    }
    
    // MARK: - TentacledAction
    struct TentacledAction: Codable {
        var clickTrackingParams: String?
        var addToPlaylistCommand: AddToPlaylistCommand?
    }
    
    // MARK: - AddToPlaylistCommand
    struct AddToPlaylistCommand: Codable {
        var openMiniplayer: Bool?
        var videoID: String?
        var listType: String?
        var onCreateListCommand: OnCreateListCommand?
        var videoIDS: [String]?
        
        enum CodingKeys: String, CodingKey {
            case openMiniplayer
            case videoID = "videoId"
            case listType, onCreateListCommand
            case videoIDS = "videoIds"
        }
    }
    
    // MARK: - OnCreateListCommand
    struct OnCreateListCommand: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var createPlaylistServiceEndpoint: CreatePlaylistServiceEndpoint?
    }
    
    // MARK: - CreatePlaylistServiceEndpoint
    struct CreatePlaylistServiceEndpoint: Codable {
        var videoIDS: [String]?
        var params: String?
        
        enum CodingKeys: String, CodingKey {
            case videoIDS = "videoIds"
            case params
        }
    }
    
    // MARK: - VideoRendererNavigationEndpoint
    struct VideoRendererNavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var watchEndpoint: NavigationEndpointWatchEndpoint?
    }
    
    // MARK: - NavigationEndpointWatchEndpoint
    struct NavigationEndpointWatchEndpoint: Codable {
        var videoID: String?
        var watchEndpointSupportedOnesieConfig: WatchEndpointSupportedOnesieConfig?
        
        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case watchEndpointSupportedOnesieConfig
        }
    }
    
    // MARK: - OwnerBadge
    struct OwnerBadge: Codable {
        var metadataBadgeRenderer: MetadataBadgeRenderer?
    }
    
    // MARK: - MetadataBadgeRenderer
    struct MetadataBadgeRenderer: Codable {
        var icon: IconImage?
        var style: String?
        var tooltip: String?
        var trackingParams: String?
        var accessibilityData: Accessibility?
    }
    
    // MARK: - PublishedTimeTextClass
    struct PublishedTimeTextClass: Codable {
        var simpleText: String?
    }
    
    // MARK: - ThumbnailOverlay
    struct ThumbnailOverlay: Codable {
        var thumbnailOverlayTimeStatusRenderer: ThumbnailOverlayTimeStatusRenderer?
        var thumbnailOverlayToggleButtonRenderer: ThumbnailOverlayToggleButtonRenderer?
        var thumbnailOverlayNowPlayingRenderer, thumbnailOverlayLoadingPreviewRenderer: ThumbnailOverlayRenderer?
        var thumbnailOverlayInlineUnplayableRenderer: ThumbnailOverlayInlineUnplayableRenderer?
    }
    
    // MARK: - ThumbnailOverlayInlineUnplayableRenderer
    struct ThumbnailOverlayInlineUnplayableRenderer: Codable {
        var text: TextClass?
        var icon: IconImage?
    }
    
    // MARK: - ThumbnailOverlayRenderer
    struct ThumbnailOverlayRenderer: Codable {
        var text: TextClass?
    }
    
    // MARK: - ThumbnailOverlayTimeStatusRenderer
    struct ThumbnailOverlayTimeStatusRenderer: Codable {
        var text: LengthTextClass?
        var style: String?
    }
    
    // MARK: - ThumbnailOverlayToggleButtonRenderer
    struct ThumbnailOverlayToggleButtonRenderer: Codable {
        var isToggled: Bool?
        var untoggledIcon, toggledIcon: IconImage?
        var untoggledTooltip: String?
        var toggledTooltip: String?
        var untoggledServiceEndpoint: UntoggledServiceEndpoint?
        var toggledServiceEndpoint: ToggledServiceEndpoint?
        var untoggledAccessibility, toggledAccessibility: AccessibilityData?
        var trackingParams: String?
    }
    
    // MARK: - ToggledServiceEndpoint
    struct ToggledServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var playlistEditEndpoint: ToggledServiceEndpointPlaylistEditEndpoint?
    }
    
    // MARK: - ToggledServiceEndpointPlaylistEditEndpoint
    struct ToggledServiceEndpointPlaylistEditEndpoint: Codable {
        var playlistID: String?
        var actions: [StickyAction]?
        
        enum CodingKeys: String, CodingKey {
            case playlistID = "playlistId"
            case actions
        }
    }
    
    // MARK: - StickyAction
    struct StickyAction: Codable {
        var action: String?
        var removedVideoID: String?
        
        enum CodingKeys: String, CodingKey {
            case action
            case removedVideoID = "removedVideoId"
        }
    }
    
    // MARK: - UntoggledServiceEndpoint
    struct UntoggledServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var playlistEditEndpoint: ServiceEndpointPlaylistEditEndpoint?
        var signalServiceEndpoint: UntoggledServiceEndpointSignalServiceEndpoint?
    }
    
    // MARK: - PurpleTitle
    struct PurpleTitle: Codable {
        var runs: [TitleRun]?
        var accessibility: AccessibilityData?
    }
    
    // MARK: - RichGridRendererHeader
    struct RichGridRendererHeader: Codable {
        var feedFilterChipBarRenderer: FeedFilterChipBarRenderer?
    }
    
    // MARK: - FeedFilterChipBarRenderer
    struct FeedFilterChipBarRenderer: Codable {
        var contents: [FeedFilterChipBarRendererContent]?
        var trackingParams: String?
        var nextButton, previousButton: VoiceSearchButtonClass?
    }
    
    // MARK: - FeedFilterChipBarRendererContent
    struct FeedFilterChipBarRendererContent: Codable {
        var chipCloudChipRenderer: ChipCloudChipRenderer?
    }
    
    // MARK: - ChipCloudChipRenderer
    struct ChipCloudChipRenderer: Codable {
        var style: StyleClass?
        var text: TextClass?
        var trackingParams: String?
        var isSelected: Bool?
        var navigationEndpoint: ChipCloudChipRendererNavigationEndpoint?
        var targetID, uniqueID: String?
        
        enum CodingKeys: String, CodingKey {
            case style, text, trackingParams, isSelected, navigationEndpoint
            case targetID = "targetId"
            case uniqueID = "uniqueId"
        }
    }
    
    // MARK: - ChipCloudChipRendererNavigationEndpoint
    struct ChipCloudChipRendererNavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var continuationCommand: NavigationEndpointContinuationCommand?
    }
    
    // MARK: - NavigationEndpointContinuationCommand
    struct NavigationEndpointContinuationCommand: Codable {
        var token: String?
        var request: String?
        var command: ContinuationCommandCommand?
    }
    
    // MARK: - ContinuationCommandCommand
    struct ContinuationCommandCommand: Codable {
        var clickTrackingParams: String?
        var showReloadUICommand: ShowReloadUICommand?
        
        enum CodingKeys: String, CodingKey {
            case clickTrackingParams
            case showReloadUICommand = "showReloadUiCommand"
        }
    }
    
    // MARK: - ShowReloadUICommand
    struct ShowReloadUICommand: Codable {
        var targetID: String?
        
        enum CodingKeys: String, CodingKey {
            case targetID = "targetId"
        }
    }
    
    
    // MARK: - StyleClass
    struct StyleClass: Codable {
        var styleType: String?
    }
    
    // MARK: - VoiceSearchDialogRenderer
    struct VoiceSearchDialogRenderer: Codable {
        var placeholderHeader, promptHeader, exampleQuery1, exampleQuery2: TextClass?
        var promptMicrophoneLabel, loadingHeader, connectionErrorHeader, connectionErrorMicrophoneLabel: TextClass?
        var permissionsHeader, permissionsSubtext, disabledHeader, disabledSubtext: TextClass?
        var microphoneButtonAriaLabel: TextClass?
        var exitButton: VoiceSearchButtonClass?
        var trackingParams: String?
        var microphoneOffPromptHeader: TextClass?
    }
    
    // MARK: - FluffyPopup
    struct FluffyPopup: Codable {
        var voiceSearchDialogRenderer: VoiceSearchDialogRenderer?
    }
    
    // MARK: - PurpleOpenPopupAction
    struct PurpleOpenPopupAction: Codable {
        var popup: FluffyPopup?
        var popupType: String?
    }
    
    // MARK: - IndigoAction
    struct IndigoAction: Codable {
        var clickTrackingParams: String?
        var openPopupAction: PurpleOpenPopupAction?
    }
    
    // MARK: - PurpleSignalServiceEndpoint
    struct PurpleSignalServiceEndpoint: Codable {
        var signal: String?
        var actions: [IndigoAction]?
    }
    
    // MARK: - FluffyServiceEndpoint
    struct FluffyServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: PurpleCommandMetadata?
        var signalServiceEndpoint: PurpleSignalServiceEndpoint?
    }
    
    // MARK: - VoiceSearchButtonButtonRenderer
    struct VoiceSearchButtonButtonRenderer: Codable {
        var style, size: String?
        var isDisabled: Bool?
        var icon: IconImage?
        var tooltip, trackingParams: String?
        var accessibilityData: AccessibilityData?
        var navigationEndpoint: ButtonRendererNavigationEndpoint?
        var accessibility: Accessibility?
        var serviceEndpoint: FluffyServiceEndpoint?
    }
    
    // MARK: - VoiceSearchButtonClass
    struct VoiceSearchButtonClass: Codable {
        var buttonRenderer: VoiceSearchButtonButtonRenderer?
    }
    
    // MARK: - PurpleCommandMetadata
    struct PurpleCommandMetadata: Codable {
        var webCommandMetadata: TentacledWebCommandMetadata?
    }
    
    // MARK: - TentacledWebCommandMetadata
    struct TentacledWebCommandMetadata: Codable {
        var sendPost: Bool?
    }
    
    // MARK: - ButtonRendererNavigationEndpoint
    struct ButtonRendererNavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var uploadEndpoint: UploadEndpoint?
    }
    
    // MARK: - ReflowOptions
    struct ReflowOptions: Codable {
        var minimumRowsOfVideosAtStart, minimumRowsOfVideosBetweenSections: Int?
    }
    
    // MARK: - FrameworkUpdates
    struct FrameworkUpdates: Codable {
        var entityBatchUpdate: EntityBatchUpdate?
    }
    
    // MARK: - EntityBatchUpdate
    struct EntityBatchUpdate: Codable {
        var mutations: [Mutation]?
        var timestamp: Timestamp?
    }
    
    // MARK: - Mutation
    struct Mutation: Codable {
        var entityKey, type: String?
        var options: Options?
    }
    
    // MARK: - Options
    struct Options: Codable {
        var persistenceOption: String?
    }
    
    // MARK: - Timestamp
    struct Timestamp: Codable {
        var seconds: String?
        var nanos: Int?
    }
    
    // MARK: - ResponseHeader
    struct ResponseHeader: Codable {
        var feedTabbedHeaderRenderer: FeedTabbedHeaderRenderer?
    }
    
    // MARK: - FeedTabbedHeaderRenderer
    struct FeedTabbedHeaderRenderer: Codable {
        var title: TextClass?
    }
    
    // MARK: - OnResponseReceivedAction
    struct OnResponseReceivedAction: Codable {
        var clickTrackingParams: String?
        var adsControlFlowOpportunityReceivedCommand: AdsControlFlowOpportunityReceivedCommand?
    }
    
    // MARK: - AdsControlFlowOpportunityReceivedCommand
    struct AdsControlFlowOpportunityReceivedCommand: Codable {
        var opportunityType: String?
        var isInitialLoad: Bool?
    }
    
    // MARK: - ResponseContext
    struct ResponseContext: Codable {
        var serviceTrackingParams: [ServiceTrackingParam]?
        var maxAgeSeconds: Int?
        var mainAppWebResponseContext: MainAppWebResponseContext?
        var webResponseContextExtensionData: WebResponseContextExtensionData?
    }
    
    // MARK: - MainAppWebResponseContext
    struct MainAppWebResponseContext: Codable {
        var datasyncID: String?
        var loggedOut: Bool?
        
        enum CodingKeys: String, CodingKey {
            case datasyncID = "datasyncId"
            case loggedOut
        }
    }
    
    // MARK: - ServiceTrackingParam
    struct ServiceTrackingParam: Codable {
        var service: String?
        var params: [Param]?
    }
    
    // MARK: - WebResponseContextExtensionData
    struct WebResponseContextExtensionData: Codable {
        var ytConfigData: YtConfigData?
        var hasDecorated: Bool?
    }
    
    // MARK: - YtConfigData
    struct YtConfigData: Codable {
        var visitorData: String?
        var sessionIndex, rootVisualElementType: Int?
    }
    
    // MARK: - Topbar
    struct Topbar: Codable {
        var desktopTopbarRenderer: DesktopTopbarRenderer?
    }
    
    // MARK: - DesktopTopbarRenderer
    struct DesktopTopbarRenderer: Codable {
        var logo: Logo?
        var searchbox: Searchbox?
        var trackingParams, countryCode: String?
        var topbarButtons: [TopbarButton]?
        var hotkeyDialog: HotkeyDialog?
        var backButton, forwardButton: BackButtonClass?
        var a11YSkipNavigationButton: A11YSkipNavigationButtonClass?
        var voiceSearchButton: VoiceSearchButtonClass?
        
        enum CodingKeys: String, CodingKey {
            case logo, searchbox, trackingParams, countryCode, topbarButtons, hotkeyDialog, backButton, forwardButton
            case a11YSkipNavigationButton = "a11ySkipNavigationButton"
            case voiceSearchButton
        }
    }
    
    // MARK: - A11YSkipNavigationButtonClass
    struct A11YSkipNavigationButtonClass: Codable {
        var buttonRenderer: A11YSkipNavigationButtonButtonRenderer?
    }
    
    // MARK: - A11YSkipNavigationButtonButtonRenderer
    struct A11YSkipNavigationButtonButtonRenderer: Codable {
        var style, size: String?
        var isDisabled: Bool?
        var text: TextClass?
        var trackingParams: String?
        var command: FluffyCommand?
    }
    
    // MARK: - FluffyCommand
    struct FluffyCommand: Codable {
        var clickTrackingParams: String?
        var commandMetadata: PurpleCommandMetadata?
        var signalServiceEndpoint: CommandSignalServiceEndpoint?
    }
    
    // MARK: - BackButtonClass
    struct BackButtonClass: Codable {
        var buttonRenderer: BackButtonButtonRenderer?
    }
    
    // MARK: - BackButtonButtonRenderer
    struct BackButtonButtonRenderer: Codable {
        var trackingParams: String?
        var command: FluffyCommand?
    }
    
    // MARK: - HotkeyDialog
    struct HotkeyDialog: Codable {
        var hotkeyDialogRenderer: HotkeyDialogRenderer?
    }
    
    // MARK: - HotkeyDialogRenderer
    struct HotkeyDialogRenderer: Codable {
        var title: TextClass?
        var sections: [Section]?
        var dismissButton: A11YSkipNavigationButtonClass?
        var trackingParams: String?
    }
    
    // MARK: - Section
    struct Section: Codable {
        var hotkeyDialogSectionRenderer: HotkeyDialogSectionRenderer?
    }
    
    // MARK: - HotkeyDialogSectionRenderer
    struct HotkeyDialogSectionRenderer: Codable {
        var title: TextClass?
        var options: [Option]?
    }
    
    // MARK: - Option
    struct Option: Codable {
        var hotkeyDialogSectionOptionRenderer: HotkeyDialogSectionOptionRenderer?
    }
    
    // MARK: - HotkeyDialogSectionOptionRenderer
    struct HotkeyDialogSectionOptionRenderer: Codable {
        var label: TextClass?
        var hotkey: String?
        var hotkeyAccessibilityLabel: AccessibilityData?
    }
    
    // MARK: - Logo
    struct Logo: Codable {
        var topbarLogoRenderer: TopbarLogoRenderer?
    }
    
    // MARK: - TopbarLogoRenderer
    struct TopbarLogoRenderer: Codable {
        var iconImage: IconImage?
        var tooltipText: TextClass?
        var endpoint: Endpoint?
        var trackingParams, overrideEntityKey: String?
    }
    
    // MARK: - Endpoint
    struct Endpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var browseEndpoint: EndpointBrowseEndpoint?
    }
    
    // MARK: - EndpointBrowseEndpoint
    struct EndpointBrowseEndpoint: Codable {
        var browseID: String?
        
        enum CodingKeys: String, CodingKey {
            case browseID = "browseId"
        }
    }
    
    // MARK: - Searchbox
    struct Searchbox: Codable {
        var fusionSearchboxRenderer: FusionSearchboxRenderer?
    }
    
    // MARK: - FusionSearchboxRenderer
    struct FusionSearchboxRenderer: Codable {
        var icon: IconImage?
        var placeholderText: TextClass?
        var config: Config?
        var trackingParams: String?
        var searchEndpoint: FusionSearchboxRendererSearchEndpoint?
        var clearButton: VoiceSearchButtonClass?
    }
    
    // MARK: - Config
    struct Config: Codable {
        var webSearchboxConfig: WebSearchboxConfig?
    }
    
    // MARK: - WebSearchboxConfig
    struct WebSearchboxConfig: Codable {
        var requestLanguage, requestDomain: String?
        var hasOnscreenKeyboard, focusSearchbox: Bool?
    }
    
    // MARK: - FusionSearchboxRendererSearchEndpoint
    struct FusionSearchboxRendererSearchEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var searchEndpoint: SearchEndpointSearchEndpoint?
    }
    
    // MARK: - SearchEndpointSearchEndpoint
    struct SearchEndpointSearchEndpoint: Codable {
        var query: String?
    }
    
    // MARK: - TopbarButton
    struct TopbarButton: Codable {
        var buttonRenderer: VoiceSearchButtonButtonRenderer?
        var notificationTopbarButtonRenderer: NotificationTopbarButtonRenderer?
        var iconBadgeTopbarButtonRenderer: IconBadgeTopbarButtonRenderer?
        var topbarMenuButtonRenderer: TopbarMenuButtonRenderer?
    }
    
    // MARK: - IconBadgeTopbarButtonRenderer
    struct IconBadgeTopbarButtonRenderer: Codable {
        var icon: Icon?
        var onClick: OnClick?
        var tooltip: String?
        var accessibilityData: AccessibilityData?
        var iconBadgeEntityKey, trackingParams: String?
    }
    
    // MARK: - Icon
    struct Icon: Codable {
        var iconBadgeRenderer: IconBadgeRenderer?
    }
    
    // MARK: - IconBadgeRenderer
    struct IconBadgeRenderer: Codable {
        var iconBadgeEntityKey: String?
        var icon: IconImage?
        var trackingParams: String?
    }
    
    // MARK: - OnClick
    struct OnClick: Codable {
        var clickTrackingParams: String?
        var commandMetadata: InlinePlaybackEndpointCommandMetadata?
        var browseEndpoint: OnClickBrowseEndpoint?
    }
    
    // MARK: - OnClickBrowseEndpoint
    struct OnClickBrowseEndpoint: Codable {
        var browseID, params, canonicalBaseURL: String?
        
        enum CodingKeys: String, CodingKey {
            case browseID = "browseId"
            case params
            case canonicalBaseURL = "canonicalBaseUrl"
        }
    }
    
    // MARK: - NotificationTopbarButtonRenderer
    struct NotificationTopbarButtonRenderer: Codable {
        var icon: IconImage?
        var menuRequest: MenuRequest?
        var style, trackingParams: String?
        var accessibility: AccessibilityData?
        var tooltip: String?
        var updateUnseenCountEndpoint: UpdateUnseenCountEndpoint?
        var notificationCount: Int?
        var handlerDatas: [String]?
    }
    
    // MARK: - MenuRequest
    struct MenuRequest: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var signalServiceEndpoint: MenuRequestSignalServiceEndpoint?
    }
    
    // MARK: - MenuRequestSignalServiceEndpoint
    struct MenuRequestSignalServiceEndpoint: Codable {
        var signal: String?
        var actions: [IndecentAction]?
    }
    
    // MARK: - IndecentAction
    struct IndecentAction: Codable {
        var clickTrackingParams: String?
        var openPopupAction: FluffyOpenPopupAction?
    }
    
    // MARK: - FluffyOpenPopupAction
    struct FluffyOpenPopupAction: Codable {
        var popup: TentacledPopup?
        var popupType: String?
        var beReused: Bool?
    }
    
    // MARK: - TentacledPopup
    struct TentacledPopup: Codable {
        var multiPageMenuRenderer: MultiPageMenuRenderer?
    }
    
    // MARK: - MultiPageMenuRenderer
    struct MultiPageMenuRenderer: Codable {
        var trackingParams, style: String?
        var showLoadingSpinner: Bool?
    }
    
    // MARK: - UpdateUnseenCountEndpoint
    struct UpdateUnseenCountEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: ContinuationEndpointCommandMetadata?
        var signalServiceEndpoint: Signal?
    }
    
    // MARK: - TopbarMenuButtonRenderer
    struct TopbarMenuButtonRenderer: Codable {
        var avatar: Avatar?
        var menuRequest: MenuRequest?
        var trackingParams: String?
        var accessibility: AccessibilityData?
        var tooltip: String?
    }
    
    // MARK: - Avatar
    struct Avatar: Codable {
        var thumbnails: [ThumbnailElement]?
        var accessibility: AccessibilityData?
    }
    
}

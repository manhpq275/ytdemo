//
//  YoutubeHistoriesResponse.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 21/10/2022.
//

import Foundation

// MARK: - YoutubeHistoriesReponse
struct YoutubeHistoriesReponse: Codable {
    var contents: Contents?
    var onResponseReceivedActions: [OnResponseReceivedActions]?
    func getContinueItem(isLoadMore: Bool) -> ContinuationItemRenderer? {
        
        guard let contents = getContents(isLoadMore: isLoadMore) else {
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
    private func getContents(isLoadMore: Bool) -> [SectionListRendererContent]? {
        if (isLoadMore) {
            return self.onResponseReceivedActions?.first?.appendContinuationItemsAction?.continuationItems
        }
        return self.contents?.twoColumnBrowseResultsRenderer?.tabs?.first?.tabRenderer?.content?.sectionListRenderer?.contents
    }
    
    func getVideos(isLoadMore: Bool) -> [VideoModel] {
        var resultList: [VideoModel] = []
        guard let sectionContents = getContents(isLoadMore: isLoadMore) else {
            return resultList
        }
        
        for sectionContent in sectionContents {
            guard let videoContents = sectionContent.itemSectionRenderer?.contents else {
                continue
            }
            let historyDate = sectionContent.itemSectionRenderer?.header?.itemSectionHeaderRenderer?.title?.runs?.first?.text
            for videoContent in videoContents {
                guard let video = videoContent.videoRenderer else {
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
                
                result.time = video.getVideoTime()
                result.id = -1

                result.thumbnail = video.thumbnail?.thumbnails?.last?.url
                result.title = video.title?.runs?.first?.text
                result.videoID = video.videoID
                result.views = video.viewCountText?.simpleText
                result.historyDate = historyDate
                resultList.append(result)
            }
          
        }
        return resultList
    }
    
    // MARK: - Contents
    struct Contents: Codable {
        var twoColumnBrowseResultsRenderer: TwoColumnBrowseResultsRenderer?
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
        var content: TabRendererContent?
    }

    // MARK: - TabRendererContent
    struct TabRendererContent: Codable {
        var sectionListRenderer: SectionListRenderer?
    }

    // MARK: - SectionListRenderer
    struct SectionListRenderer: Codable {
        var contents: [SectionListRendererContent]?
    }

    // MARK: - SectionListRendererContent
    struct SectionListRendererContent: Codable {
        var itemSectionRenderer: ItemSectionRenderer?
        var continuationItemRenderer: ContinuationItemRenderer?
    }

    // MARK: - ContinuationItemRenderer
    struct ContinuationItemRenderer: Codable {
        var continuationEndpoint: ContinuationEndpoint?
    }

    // MARK: - ContinuationEndpoint
    struct ContinuationEndpoint: Codable {
        var clickTrackingParams: String?
        var continuationCommand: ContinuationCommand?
    }

    // MARK: - ContinuationCommand
    struct ContinuationCommand: Codable {
        var token: String?
    }

    // MARK: - ItemSectionRenderer
    struct ItemSectionRenderer: Codable {
        var contents: [ItemSectionRendererContent]?
        var header: ItemSectionRendererHeader?
    }
    
    struct ItemSectionRendererHeader: Codable {
        var itemSectionHeaderRenderer: ItemSectionHeaderRendererHeader?
    }

    struct ItemSectionHeaderRendererHeader: Codable {
        var title: LongBylineTextClass?
    }
    // MARK: - ItemSectionRendererContent
    struct ItemSectionRendererContent: Codable {
        var videoRenderer: VideoRenderer?
    }

    // MARK: - VideoRenderer
    struct VideoRenderer: Codable {
        var videoID: String?
        var thumbnail: ReelWatchEndpointThumbnail?
        var title: Title?
        var descriptionSnippet: DescriptionSnippet?
        var longBylineText: LongBylineTextClass?
        var lengthText: LengthTextClass?
        var viewCountText: ViewCountTextClass?
        var navigationEndpoint: VideoRendererNavigationEndpoint?
        var ownerBadges: [OwnerBadge]?
        var ownerText, shortBylineText: LongBylineTextClass?
        var trackingParams: String?
        var showActionMenu: Bool?
        var shortViewCountText: LengthTextClass?
        var isWatched: Bool?
        var menu: Menu?
        var channelThumbnailSupportedRenderers: ChannelThumbnailSupportedRenderers?
        var thumbnailOverlays: [ThumbnailOverlay]?
        var richThumbnail: RichThumbnail?
        var topStandaloneBadge: TopStandaloneBadge?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case thumbnail, title, descriptionSnippet, longBylineText, lengthText, viewCountText, navigationEndpoint, ownerBadges, ownerText, shortBylineText, trackingParams, showActionMenu, shortViewCountText, isWatched, menu, channelThumbnailSupportedRenderers, thumbnailOverlays, richThumbnail, topStandaloneBadge
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
        var thumbnail: ChannelThumbnailClass?
        var navigationEndpoint: NavigationEndpoint?
        var accessibility: Accessibility?
    }

    // MARK: - Accessibility
    struct Accessibility: Codable {
        var accessibilityData: AccessibilityData?
    }

    // MARK: - AccessibilityData
    struct AccessibilityData: Codable {
        var label: String?
    }

    // MARK: - NavigationEndpoint
    struct NavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: NavigationEndpointCommandMetadata?
        var browseEndpoint: BrowseEndpoint?
    }

    // MARK: - BrowseEndpoint
    struct BrowseEndpoint: Codable {
        var browseID, canonicalBaseURL: String?

        enum CodingKeys: String, CodingKey {
            case browseID = "browseId"
            case canonicalBaseURL = "canonicalBaseUrl"
        }
    }

    // MARK: - NavigationEndpointCommandMetadata
    struct NavigationEndpointCommandMetadata: Codable {
        var webCommandMetadata: PurpleWebCommandMetadata?
    }

    // MARK: - PurpleWebCommandMetadata
    struct PurpleWebCommandMetadata: Codable {
        var url: String?
        var webPageType: String?
        var rootVe: Int?
        var apiURL: String?

        enum CodingKeys: String, CodingKey {
            case url, webPageType, rootVe
            case apiURL = "apiUrl"
        }
    }

    // MARK: - ChannelThumbnailClass
    struct ChannelThumbnailClass: Codable {
        var thumbnails: [ThumbnailElement]?
    }

    // MARK: - ThumbnailElement
    struct ThumbnailElement: Codable {
        var url: String?
        var width, height: Int?
    }

    // MARK: - DescriptionSnippet
    struct DescriptionSnippet: Codable {
        var runs: [DescriptionSnippetRun]?
    }

    // MARK: - DescriptionSnippetRun
    struct DescriptionSnippetRun: Codable {
        var text: String?
    }

    // MARK: - LengthTextClass
    struct LengthTextClass: Codable {
        var accessibility: Accessibility?
        var simpleText: String?
    }

    // MARK: - LongBylineTextClass
    struct LongBylineTextClass: Codable {
        var runs: [LongBylineTextRun]?
    }

    // MARK: - LongBylineTextRun
    struct LongBylineTextRun: Codable {
        var text: String?
        var navigationEndpoint: NavigationEndpoint?
    }

    // MARK: - Menu
    struct Menu: Codable {
        var menuRenderer: MenuRenderer?
    }

    // MARK: - MenuRenderer
    struct MenuRenderer: Codable {
        var items: [ItemElement]?
        var trackingParams: String?
        var topLevelButtons: [TopLevelButton]?
        var accessibility: Accessibility?
    }

    // MARK: - ItemElement
    struct ItemElement: Codable {
        var menuServiceItemRenderer: MenuServiceItemRenderer?
        var menuServiceItemDownloadRenderer: MenuServiceItemDownloadRenderer?
    }

    // MARK: - MenuServiceItemDownloadRenderer
    struct MenuServiceItemDownloadRenderer: Codable {
        var serviceEndpoint: MenuServiceItemDownloadRendererServiceEndpoint?
        var trackingParams: String?
    }

    // MARK: - MenuServiceItemDownloadRendererServiceEndpoint
    struct MenuServiceItemDownloadRendererServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var offlineVideoEndpoint: OfflineVideoEndpoint?
    }

    // MARK: - OfflineVideoEndpoint
    struct OfflineVideoEndpoint: Codable {
        var videoID: String?
        var onAddCommand: OnAddCommand?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case onAddCommand
        }
    }

    // MARK: - OnAddCommand
    struct OnAddCommand: Codable {
        var clickTrackingParams: String?
        var getDownloadActionCommand: GetDownloadActionCommand?
    }

    // MARK: - GetDownloadActionCommand
    struct GetDownloadActionCommand: Codable {
        var videoID: String?
        var params: String?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case params
        }
    }

    // MARK: - MenuServiceItemRenderer
    struct MenuServiceItemRenderer: Codable {
        var text: DescriptionSnippet?
        var icon: Icon?
        var serviceEndpoint: ServiceEndpoint?
        var trackingParams: String?
        var hasSeparator: Bool?
    }

    // MARK: - Icon
    struct Icon: Codable {
        var iconType: String?
    }


    // MARK: - ServiceEndpoint
    struct ServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: UntoggledServiceEndpointCommandMetadata?
        var signalServiceEndpoint: SignalServiceEndpoint?
        var playlistEditEndpoint: UntoggledServiceEndpointPlaylistEditEndpoint?
        var addToPlaylistServiceEndpoint: AddToPlaylistServiceEndpoint?
    }

    // MARK: - AddToPlaylistServiceEndpoint
    struct AddToPlaylistServiceEndpoint: Codable {
        var videoID: String?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
        }
    }

    // MARK: - UntoggledServiceEndpointCommandMetadata
    struct UntoggledServiceEndpointCommandMetadata: Codable {
        var webCommandMetadata: FluffyWebCommandMetadata?
    }

    // MARK: - FluffyWebCommandMetadata
    struct FluffyWebCommandMetadata: Codable {
        var sendPost: Bool?
        var apiURL: String?

        enum CodingKeys: String, CodingKey {
            case sendPost
            case apiURL = "apiUrl"
        }
    }

    // MARK: - UntoggledServiceEndpointPlaylistEditEndpoint
    struct UntoggledServiceEndpointPlaylistEditEndpoint: Codable {
        var playlistID: String?
        var actions: [PurpleAction]?

        enum CodingKeys: String, CodingKey {
            case playlistID = "playlistId"
            case actions
        }
    }

    // MARK: - PurpleAction
    struct PurpleAction: Codable {
        var addedVideoID: String?
        var action: String?

        enum CodingKeys: String, CodingKey {
            case addedVideoID = "addedVideoId"
            case action
        }
    }

    // MARK: - SignalServiceEndpoint
    struct SignalServiceEndpoint: Codable {
        var signal: String?
        var actions: [SignalServiceEndpointAction]?
    }

    // MARK: - SignalServiceEndpointAction
    struct SignalServiceEndpointAction: Codable {
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
        var commandMetadata: UntoggledServiceEndpointCommandMetadata?
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


    // MARK: - TopLevelButton
    struct TopLevelButton: Codable {
        var buttonRenderer: TopLevelButtonButtonRenderer?
    }

    // MARK: - TopLevelButtonButtonRenderer
    struct TopLevelButtonButtonRenderer: Codable {
        var style: String?
        var size: String?
        var isDisabled: Bool?
        var serviceEndpoint: ButtonRendererServiceEndpoint?
        var icon: Icon?
        var tooltip: String?
        var trackingParams: String?
        var accessibilityData: Accessibility?
    }

    // MARK: - ButtonRendererServiceEndpoint
    struct ButtonRendererServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: UntoggledServiceEndpointCommandMetadata?
        var feedbackEndpoint: FeedbackEndpoint?
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
        var hideItemSectionVideosByIDCommand: AddToPlaylistServiceEndpoint?
        var openPopupAction: OpenPopupAction?

        enum CodingKeys: String, CodingKey {
            case clickTrackingParams, replaceEnclosingAction
            case hideItemSectionVideosByIDCommand = "hideItemSectionVideosByIdCommand"
            case openPopupAction
        }
    }

    // MARK: - OpenPopupAction
    struct OpenPopupAction: Codable {
        var popup: Popup?
        var popupType: String?
    }

    // MARK: - Popup
    struct Popup: Codable {
        var notificationActionRenderer: NotificationActionRenderer?
    }

    // MARK: - NotificationActionRenderer
    struct NotificationActionRenderer: Codable {
        var responseText: LengthTextClass?
        var trackingParams: String?
    }

    // MARK: - ReplaceEnclosingAction
    struct ReplaceEnclosingAction: Codable {
        var item: ReplaceEnclosingActionItem?
    }

    // MARK: - ReplaceEnclosingActionItem
    struct ReplaceEnclosingActionItem: Codable {
        var notificationMultiActionRenderer: NotificationActionRenderer?
    }

    // MARK: - UIActions
    struct UIActions: Codable {
        var hideEnclosingContainer: Bool?
    }


    // MARK: - VideoRendererNavigationEndpoint
    struct VideoRendererNavigationEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: NavigationEndpointCommandMetadata?
        var watchEndpoint: WatchEndpoint?
        var reelWatchEndpoint: ReelWatchEndpoint?
    }

    // MARK: - ReelWatchEndpoint
    struct ReelWatchEndpoint: Codable {
        var videoID, playerParams: String?
        var thumbnail: ReelWatchEndpointThumbnail?
        var overlay: Overlay?
        var params, sequenceProvider, sequenceParams: String?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case playerParams, thumbnail, overlay, params, sequenceProvider, sequenceParams
        }
    }

    // MARK: - Overlay
    struct Overlay: Codable {
        var reelPlayerOverlayRenderer: ReelPlayerOverlayRenderer?
    }

    // MARK: - ReelPlayerOverlayRenderer
    struct ReelPlayerOverlayRenderer: Codable {
        var reelPlayerHeaderSupportedRenderers: ReelPlayerHeaderSupportedRenderers?
        var nextItemButton, prevItemButton: ItemButton?
        var style, trackingParams: String?
    }

    // MARK: - ItemButton
    struct ItemButton: Codable {
        var buttonRenderer: NextItemButtonButtonRenderer?
    }

    // MARK: - NextItemButtonButtonRenderer
    struct NextItemButtonButtonRenderer: Codable {
        var trackingParams: String?
    }

    // MARK: - ReelPlayerHeaderSupportedRenderers
    struct ReelPlayerHeaderSupportedRenderers: Codable {
        var reelPlayerHeaderRenderer: ReelPlayerHeaderRenderer?
    }

    // MARK: - ReelPlayerHeaderRenderer
    struct ReelPlayerHeaderRenderer: Codable {
        var reelTitleText: ReelTitleText?
        var timestampText: ViewCountTextClass?
        var channelNavigationEndpoint: NavigationEndpoint?
        var channelTitleText: LongBylineTextClass?
        var channelThumbnail: ChannelThumbnailClass?
        var trackingParams: String?
        var accessibility: Accessibility?
    }

    // MARK: - ReelTitleText
    struct ReelTitleText: Codable {
        var runs: [ReelTitleTextRun]?
    }

    // MARK: - ReelTitleTextRun
    struct ReelTitleTextRun: Codable {
        var text: String?
        var loggingDirectives: LoggingDirectives?
    }

    // MARK: - LoggingDirectives
    struct LoggingDirectives: Codable {
        var trackingParams: String?
        var visibility: Visibility?
        var enableDisplayloggerExperiment: Bool?
    }

    // MARK: - Visibility
    struct Visibility: Codable {
        var types: String?
    }

    // MARK: - ViewCountTextClass
    struct ViewCountTextClass: Codable {
        var simpleText: String?
    }

    // MARK: - ReelWatchEndpointThumbnail
    struct ReelWatchEndpointThumbnail: Codable {
        var thumbnails: [ThumbnailElement]?
        var isOriginalAspectRatio: Bool?
    }

    // MARK: - WatchEndpoint
    struct WatchEndpoint: Codable {
        var videoID: String?
        var watchEndpointSupportedOnesieConfig: WatchEndpointSupportedOnesieConfig?
        var params: String?
        var startTimeSeconds: Int?

        enum CodingKeys: String, CodingKey {
            case videoID = "videoId"
            case watchEndpointSupportedOnesieConfig, params, startTimeSeconds
        }
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

    // MARK: - OwnerBadge
    struct OwnerBadge: Codable {
        var metadataBadgeRenderer: OwnerBadgeMetadataBadgeRenderer?
    }

    // MARK: - OwnerBadgeMetadataBadgeRenderer
    struct OwnerBadgeMetadataBadgeRenderer: Codable {
        var icon: Icon?
        var style: String?
        var tooltip: String?
        var trackingParams: String?
        var accessibilityData: AccessibilityData?
    }


    // MARK: - RichThumbnail
    struct RichThumbnail: Codable {
        var movingThumbnailRenderer: MovingThumbnailRenderer?
    }

    // MARK: - MovingThumbnailRenderer
    struct MovingThumbnailRenderer: Codable {
        var movingThumbnailDetails: MovingThumbnailDetails?
        var enableHoveredLogging, enableOverlay: Bool?
    }

    // MARK: - MovingThumbnailDetails
    struct MovingThumbnailDetails: Codable {
        var thumbnails: [ThumbnailElement]?
        var logAsMovingThumbnail: Bool?
    }

    // MARK: - ThumbnailOverlay
    struct ThumbnailOverlay: Codable {
        var thumbnailOverlayResumePlaybackRenderer: ThumbnailOverlayResumePlaybackRenderer?
        var thumbnailOverlayTimeStatusRenderer: ThumbnailOverlayTimeStatusRenderer?
        var thumbnailOverlayToggleButtonRenderer: ThumbnailOverlayToggleButtonRenderer?
        var thumbnailOverlayNowPlayingRenderer: ThumbnailOverlayNowPlayingRenderer?
    }

    // MARK: - ThumbnailOverlayNowPlayingRenderer
    struct ThumbnailOverlayNowPlayingRenderer: Codable {
        var text: DescriptionSnippet?
    }

    // MARK: - ThumbnailOverlayResumePlaybackRenderer
    struct ThumbnailOverlayResumePlaybackRenderer: Codable {
        var percentDurationWatched: Int?
    }

    // MARK: - ThumbnailOverlayTimeStatusRenderer
    struct ThumbnailOverlayTimeStatusRenderer: Codable {
        var text: Text?
        var style: String?
        var icon: Icon?
    }

    // MARK: - Text
    struct Text: Codable {
        var accessibility: Accessibility?
        var simpleText: String?
        var runs: [DescriptionSnippetRun]?
    }

    // MARK: - ThumbnailOverlayToggleButtonRenderer
    struct ThumbnailOverlayToggleButtonRenderer: Codable {
        var isToggled: Bool?
        var untoggledIcon, toggledIcon: Icon?
        var untoggledTooltip: String?
        var toggledTooltip: String?
        var untoggledServiceEndpoint: ServiceEndpoint?
        var toggledServiceEndpoint: ToggledServiceEndpoint?
        var untoggledAccessibility, toggledAccessibility: Accessibility?
        var trackingParams: String?
    }

    // MARK: - ToggledServiceEndpoint
    struct ToggledServiceEndpoint: Codable {
        var clickTrackingParams: String?
        var commandMetadata: UntoggledServiceEndpointCommandMetadata?
        var playlistEditEndpoint: ToggledServiceEndpointPlaylistEditEndpoint?
    }

    // MARK: - ToggledServiceEndpointPlaylistEditEndpoint
    struct ToggledServiceEndpointPlaylistEditEndpoint: Codable {
        var playlistID: String?
        var actions: [FluffyAction]?

        enum CodingKeys: String, CodingKey {
            case playlistID = "playlistId"
            case actions
        }
    }

    // MARK: - FluffyAction
    struct FluffyAction: Codable {
        var action: String?
        var removedVideoID: String?

        enum CodingKeys: String, CodingKey {
            case action
            case removedVideoID = "removedVideoId"
        }
    }

    // MARK: - Title
    struct Title: Codable {
        var runs: [DescriptionSnippetRun]?
        var accessibility: Accessibility?
    }

    // MARK: - TopStandaloneBadge
    struct TopStandaloneBadge: Codable {
        var metadataBadgeRenderer: TopStandaloneBadgeMetadataBadgeRenderer?
    }

    // MARK: - TopStandaloneBadgeMetadataBadgeRenderer
    struct TopStandaloneBadgeMetadataBadgeRenderer: Codable {
        var style, label, trackingParams: String?
    }
    
    struct OnResponseReceivedActions: Codable {
        var appendContinuationItemsAction: AppendContinuationItemsAction?
    }
    
    struct AppendContinuationItemsAction: Codable {
        var continuationItems: [SectionListRendererContent]?
    }

}

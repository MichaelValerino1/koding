class ContentDisplayStatusUpdate extends ActivityContentDisplay

  constructor:(options = {}, data={})->

    options.tooltip or=
      title     : "Status Update"
      offset    : 3
      selector  : "span.type-icon"

    super options,data

    embedOptions = $.extend {}, options, {
      hasDropdown : no
      delegate : @
      maxWidth : 700
    }

    if data.link?
      @embedBox = new EmbedBox @embedOptions, data?.link
    else
      @embedBox = new KDView
    origin =
      constructorName  : data.originType
      id               : data.originId

    @avatar = new AvatarStaticView
      tagName : "span"
      size    : {width: 50, height: 50}
      origin  : origin

    @author = new ProfileLinkView {origin}

    @commentBox = new CommentView null, data

    @actionLinks = new ActivityActionsView
      delegate : @commentBox.commentList
      cssClass : "comment-header"
    , data

    @tags = new ActivityChildViewTagGroup
      itemsToShow   : 3
      itemClass  : TagLinkView
    , data.tags

  attachTooltipAndEmbedInteractivity:=>
    @$("p.status-body > span.data > a").each (i,element)=>
      href = $(element).attr("data-original-url") or $(element).attr("href") or ""

      twOptions = (title) ->
         title : title, placement : "above", offset : 3, delayIn : 300, html : yes, animate : yes, className : "link-expander"

      unless /^(#!)/.test href
        $(element).twipsy twOptions("External Link : <span>"+href+"</span>")
      element


  viewAppended:()->
    return if @getData().constructor is KD.remote.api.CStatusActivity
    super()
    @setTemplate @pistachio()
    @template.update()

    # load embed on next callstack

    @utils.wait =>

      # If there is embed data in the model, use that!
      if @getData().link?.link_url? and not (@getData().link.link_url is "")

        if not ("embed" in @getData()?.link?.link_embed_hidden_items)

          @embedBox.show()
          @embedBox.$().fadeIn 200

          firstUrl = @getData().body.match(/(([a-zA-Z]+\:)?\/\/)+(\w+:\w+@)?([a-zA-Z\d.-]+\.[A-Za-z]{2,4})(:\d+)?(\/\S*)?/g)
          if firstUrl?
            @embedBox.embedLinks.setLinks firstUrl

          @embedBox.embedExistingData @getData().link.link_embed, {
            maxWidth: 700
            maxHeight: 300
          }, =>

            @embedBox.setActiveLink @getData().link.link_url

          , @getData().link.link_cache


          @embedBox.embedLinks.hide()

        else
          @embedBox.hide()

      else
        @embedBox.hide()

      @attachTooltipAndEmbedInteractivity()

    # temp for beta
    # take this bit to comment view
    if @getData().repliesCount? and @getData().repliesCount > 0
      commentController = @commentBox.commentController
      commentController.fetchAllComments 0, (err, comments)->
        commentController.removeAllItems()
        commentController.instantiateListItems comments

  render:=>
    super

    {link} = @getData()

    if link?
      if @embedBox.constructor.name is "KDView"
        @embedBox = new EmbedBox @embedOptions, link
      @embedBox.setEmbedHiddenItems link.link_embed_hidden_items
      @embedBox.setEmbedImageIndex link.link_embed_image_index
      @embedBox.embedExistingData link.link_embed, {} ,=>
        if "embed" in link.link_embed_hidden_items
          @embedBox.hide()
      , link.link_cache

      @embedBox.setActiveLink link.link_url

    else
      @embedBox = new KDView
    @attachTooltipAndEmbedInteractivity()

  pistachio:->

    """
    {{> @header}}
    <h2 class="sub-header">{{> @back}}</h2>
    <div class='kdview content-display-main-section activity-item status'>
      <span>
        {{> @avatar}}
        <span class="author">AUTHOR</span>
      </span>
      <div class='activity-item-right-col'>
        <h3 class='hidden'></h3>
        <p class="status-body">{{@utils.applyTextExpansions #(body)}}</p>
        {{> @embedBox}}
        <footer class='clearfix'>
          <div class='type-and-time'>
            <span class='type-icon'></span> by {{> @author}}
            <time>{{$.timeago #(meta.createdAt)}}</time>
            {{> @tags}}
          </div>
          {{> @actionLinks}}
        </footer>
        {{> @commentBox}}
      </div>
    </div>
    """
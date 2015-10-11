{Range, Point, CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports =
class SwacketsView

    intervalID = null

    constructor: ->
        @sweatify()

        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
            @sweatify()
            editor = atom.workspace.getActiveTextEditor()
            return unless editor
            @subscriptions.add editor.onDidChange(@sweatify)

        intervalID = setInterval =>
            @sweatify()
        , 100

        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        @subscriptions.add editor.onDidChange(@sweatify)

        @subscriptions.add atom.commands.add 'atom-workspace', 'swackets:toggle': => @toggle()

    destroy: ->
        clearInterval(intervalID)
        @subscriptions.dispose()



    sweatify: ->
        sweatyness = 0
        colors = ['#ff3333']
        colors = colors.concat(atom.config.get('swackets.colors'))

        setTimeout ->

            lineGroups = $("atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div")
            numLineGroups = lineGroups.toArray().length
            firstGroup = undefined;

            while numLineGroups >= 0
                singleGroup = $(lineGroups).filter -> $(this).css('zIndex') == (''+numLineGroups)

                if (!firstGroup and singleGroup.length >= 1)
                    firstLine = $(singleGroup).children(".line").first().attr('data-screen-row')
                    range = new Range(new Point(0, 0), new Point(Number(firstLine), 0))
                    editor = atom.workspace.getActiveTextEditor()
                    return unless editor
                    northOfTheScroll = editor.getTextInBufferRange(range)
                    unseenLength = northOfTheScroll.length

                    curChar = 0
                    curSpeechChar = undefined #TODO omit comments and speechmarks (HARD)
                    while (curChar < unseenLength)

                        if (northOfTheScroll[curChar] == '{')
                            sweatyness++
                        else if (northOfTheScroll[curChar] == '}')
                            sweatyness = Math.max.apply @, [(sweatyness-1), 0]

                        curChar++

                    firstGroup = true
                    ####DONE WITH PRE-BUFFER GUESSTIMATION####

                $(singleGroup).find('span').each (index, element) =>
                    if ($(element).html()[0] == '{' || $(element).html()[1] == '{')
                        sweatyness++
                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                        $(element).css('color', colors[sweatcap])

                    if ($(element).html()[0] == '}' || $(element).html()[1] == '}')
                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                        $(element).css('color', colors[sweatcap])

                        sweatyness = Math.max.apply @, [(sweatyness-1), 0]


                numLineGroups-- #END OF WHILE#
        , 24


    toggle: ->
        console.log 'TODO switch to decoration'

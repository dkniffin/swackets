{Range, Point} = require 'atom'
$ = require 'jquery'

module.exports =
class SwacketsView

    constructor: ->
        @sweatify()
        editor = atom.workspace.getActiveTextEditor()
        return unless editor

        editor.onDidChange(@sweatify)
        setInterval =>
            @sweatify()
        , 100

        atom.workspace.onDidChangeActivePaneItem =>
            @sweatify()
            editor = atom.workspace.getActiveTextEditor()
            return unless editor
            editor.onDidChange(@sweatify)


    sweatify: ->
        sweatyness = 0
        colors = ['#ff3333', '#ba8cb8', '#8ab7d8', '#60dd60', '#ffff70', '#ea9d70', '#ff7070']

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

                        curChar++ ##WHILE##

                    firstGroup = true
                    ####DONE WITH PRE-BUFFER GUESSTIMATION####

                $(singleGroup).find('span').each (index, element) =>

                    if ($(element).html()[0] == '{')
                        sweatyness++

                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                        $(element).css('color', colors[sweatcap])


                    if ($(element).html()[0] == '}')
                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, colors.length - 1]
                        $(element).css('color', colors[sweatcap])

                        sweatyness = Math.max.apply @, [(sweatyness-1), 0]

                numLineGroups-- ##WHILE##
        , 24

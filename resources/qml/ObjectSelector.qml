// Copyright (c) 2019 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.2 as UM
import Cura 1.0 as Cura

Item
{
    id: objectSelector
    width: UM.Theme.getSize("objects_menu_size").width
    property bool opened: UM.Preferences.getValue("cura/show_list_of_objects")

    // Eat up all the mouse events (we don't want the scene to react or have the scene context menu showing up)
    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Button
    {
        id: openCloseButton
        width: parent.width
        height: contentItem.height + bottomPadding
        hoverEnabled: true
        padding: 0
        bottomPadding: UM.Theme.getSize("narrow_margin").height / 2 | 0

        anchors
        {
            bottom: contents.top
            horizontalCenter: parent.horizontalCenter
        }

        contentItem: Item
        {
            width: parent.width
            height: label.height

            UM.RecolorImage
            {
                id: openCloseIcon
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                sourceSize.width: width
                anchors.left: parent.left
                color: openCloseButton.hovered ? UM.Theme.getColor("small_button_text_hover") : UM.Theme.getColor("small_button_text")
                source: objectSelector.opened ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_top")
            }

            Label
            {
                id: label
                anchors.left: openCloseIcon.right
                anchors.leftMargin: UM.Theme.getSize("default_margin").width
                text: catalog.i18nc("@label", "Object list")
                font: UM.Theme.getFont("default")
                color: openCloseButton.hovered ? UM.Theme.getColor("small_button_text_hover") : UM.Theme.getColor("small_button_text")
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }
        }

        background: Item {}

        onClicked:
        {
            UM.Preferences.setValue("cura/show_list_of_objects", !objectSelector.opened)
            objectSelector.opened = UM.Preferences.getValue("cura/show_list_of_objects")
        }
    }

    Rectangle
    {
        id: contents
        width: parent.width
        visible: objectSelector.opened
        height: visible ? scroll.height : 0
        color: UM.Theme.getColor("main_background")
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")

        Behavior on height { NumberAnimation { duration: 100 } }

        anchors.bottom: parent.bottom

        ScrollView
        {
            id: scroll
            width: parent.width
            clip: true
            padding: UM.Theme.getSize("default_lining").width

            contentItem: ListView
            {
                id: listView

                // Can't use parent.width since the parent is the flickable component and not the ScrollView
                width: scroll.width - scroll.leftPadding - scroll.rightPadding
                property real maximumHeight: UM.Theme.getSize("objects_menu_size").height

                // We use an extra property here, since we only want to to be informed about the content size changes.
                onContentHeightChanged:
                {
                    // It can sometimes happen that (due to animations / updates) the contentHeight is -1.
                    // This can cause a bunch of updates to trigger oneother, leading to a weird loop. 
                    if(contentHeight >= 0)
                    {
                        scroll.height = Math.min(contentHeight, maximumHeight) + scroll.topPadding + scroll.bottomPadding
                    }
                }

                Component.onCompleted:
                {
                    scroll.height = Math.min(contentHeight, maximumHeight) + scroll.topPadding + scroll.bottomPadding
                }
                model: Cura.ObjectsModel {}

                delegate: ObjectItemButton
                {
                    id: modelButton
                    Binding
                    {
                        target: modelButton
                        property: "checked"
                        value: model.selected
                    }
                    text: model.name
                    width: listView.width
                }
            }
        }
    }
}

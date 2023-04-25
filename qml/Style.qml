pragma Singleton
import QtQuick
import "themes"
Theme {
    property int cur:2
    property Theme current: if(cur==1)
        return theme1
    else return theme2
    property Theme theme1: Theme1 { }
    property Theme theme2: Theme2 { }
    bgColor: (current && current.bgColor ? current.bgColor : 'defaultBgColor')
    fColor: (current && current.fColor ? current.fColor : 'defaultFColor')
    sColor: (current && current.sColor ? current.sColor : 'defaultSColor')
    hColor: (current && current.hColor ? current.hColor : 'defaultHColor')
    oColor: (current && current.oColor ? current.oColor : 'defaultOColor')
    textColor: (current && current.textColor ? current.textColor : 'defaultTextColor')
    scrollColor: (current && current.scrollColor ? current.scrollColor : 'defaultScrollColor')
}

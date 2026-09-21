                ShapeField {
                    id: passwordField
                    Layout.topMargin: 30
                    Layout.fillWidth: true
                    focus: loginState.visible
                    enabled: !container.isLoggingIn
                    font.family: activeFontRegular
                    accent: container.extractedAccent
                    onAccepted: container.doLogin()
                }

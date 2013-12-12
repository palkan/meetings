package ru.teachbase.utils.shortcuts {
import ru.teachbase.components.notifications.Notification;
import ru.teachbase.model.App;

/**
 * Show notification
 *  @param notification
 *  @param allowForUser Define whether to show this notification to users (not administrators).
 *
 */
public function notify(notification:Notification, allowForUsers:Boolean = false):void {
    if (!App.user.settings || !App.user.settings.shownotifications || (!App.user.isAdmin() && !allowForUsers)) {
        return;
    }

    App.view.notification(notification);
}
}
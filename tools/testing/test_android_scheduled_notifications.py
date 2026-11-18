"""Check Android components required by flutter_local_notifications scheduling."""
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


MANIFEST = Path(__file__).resolve().parents[2] / 'android/app/src/main/AndroidManifest.xml'
ANDROID = '{http://schemas.android.com/apk/res/android}'
PLUGIN = 'com.dexterous.flutterlocalnotifications.'


class ScheduledNotificationsManifestTest(unittest.TestCase):
    def setUp(self):
        self.manifest = ET.parse(MANIFEST).getroot()
        self.application = self.manifest.find('application')
        self.assertIsNotNone(self.application)

    def receiver(self, name):
        matches = [item for item in self.application.findall('receiver')
                   if item.get(ANDROID + 'name') == PLUGIN + name]
        self.assertEqual(len(matches), 1, f'{name} must be declared exactly once')
        self.assertEqual(matches[0].get(ANDROID + 'exported'), 'false')
        return matches[0]

    def test_scheduled_delivery_receiver_is_private(self):
        receiver = self.receiver('ScheduledNotificationReceiver')
        self.assertEqual(receiver.findall('intent-filter'), [])

    def test_boot_receiver_restores_schedules_after_restart_or_update(self):
        receiver = self.receiver('ScheduledNotificationBootReceiver')
        actions = [action.get(ANDROID + 'name')
                   for action in receiver.findall('intent-filter/action')]
        self.assertCountEqual(actions, [
            'android.intent.action.BOOT_COMPLETED',
            'android.intent.action.MY_PACKAGE_REPLACED',
            'android.intent.action.QUICKBOOT_POWERON',
            'com.htc.intent.action.QUICKBOOT_POWERON',
        ])

    def test_boot_permission_does_not_add_exact_alarm_authority(self):
        permissions = [item.get(ANDROID + 'name')
                       for item in self.manifest.findall('uses-permission')]
        self.assertEqual(permissions.count('android.permission.RECEIVE_BOOT_COMPLETED'), 1)
        self.assertNotIn('android.permission.SCHEDULE_EXACT_ALARM', permissions)
        self.assertNotIn('android.permission.USE_EXACT_ALARM', permissions)


if __name__ == '__main__':
    unittest.main()

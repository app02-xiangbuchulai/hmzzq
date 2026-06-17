// entry/src/main/ets/entrybackupability/EntryBackupAbility.ets
import { UIAbility } from '@kit.AbilityKit';

export default class EntryBackupAbility extends UIAbility {
  onCreate(): void {
    console.info('EntryBackupAbility onCreate');
  }

  onDestroy(): void {
    console.info('EntryBackupAbility onDestroy');
  }
}
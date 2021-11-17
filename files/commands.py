import os
import shutil

from ranger.api.commands import Command
from ranger.ext.safe_path import get_safe_path


class backup_edit(Command):
    def execute(self):
        if self.arg(1):
            original_filename = self.rest(1)
        else:
            original_filename = self.fm.thisfile.path

        if not os.path.exists(original_filename):
            self.fm.notify(f"{original_filename} does not exist", bad=True)
            return

        if os.path.isdir(original_filename):
            self.fm.notify(f"{original_filename} is a directory", bad=True)
            return

        backup_ext = ".link" if os.path.islink(original_filename) else ".bak"

        new_filename = get_safe_path(original_filename + backup_ext)

        if not self.fm.rename(original_filename, new_filename):
            self.fm.notify(f"Failed to rename file")
            return

        shutil.copyfile(new_filename, original_filename, follow_symlinks=True)

        self.fm.edit_file(original_filename)

    def tab(self, tabnum):
        return self._tab_directory_content()

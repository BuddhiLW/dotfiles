vim9script
# hive-vessel: one Vim plugin for both directions of the hive editor wire.
#
# Outbound, hive drives Vim: :vim-channel natives ["call", "hive_vessel#...",
# args] paint panels through autoload/hive_vessel.vim. Inbound, Vim answers
# hive's HiveOp calls (autoload/hive_vessel/ops.vim). Both travel the one JSON
# channel that autoload/hive_vessel/wire.vim discovers and authenticates.
#
#   :HiveVesselConnect              discovery file + token (the default; automatic)
#   :HiveVesselConnect 127.0.0.1:N  manual fallback: a raw channel to
#                                   hive-vessel.executor.vim-channel, no hello
#   :HiveVesselDisconnect  :HiveVesselStatus  :HiveVesselShowTerminal {id}
#
# Options: g:hive_vessel_autoconnect (1), g:hive_vessel_retry_ms (3000),
# g:hive_vessel_discovery_dir, g:hive_vessel_headless, g:hive_vessel_faces.
#
# SPDX-License-Identifier: MIT

if exists('g:loaded_hive_vessel') || v:version < 900 || !has('channel')
  finish
endif
g:loaded_hive_vessel = 1

import autoload 'hive_vessel/wire.vim'

def g:HiveOp(op: string, params: any): dict<any>
  return wire.Op(op, params)
enddef

command! -nargs=? HiveVesselConnect wire.Connect(<q-args>)
command! HiveVesselDisconnect wire.Disconnect()
command! HiveVesselStatus echo wire.Status()
command! -nargs=1 HiveVesselShowTerminal wire.ShowTerminal(<q-args>)

augroup hive_vessel
  autocmd!
  autocmd VimEnter * wire.Start()
  autocmd FocusGained * wire.SendEvent('focus', {})
  autocmd VimLeavePre * wire.Disconnect()
augroup END

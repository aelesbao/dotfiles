" vim source for conventional commits (https://www.conventionalcommits.org)
function! coc#source#conventional_commit#init() abort
  return {
        \ 'priority': 0,
        \ 'shortcut': 'Commit Type',
        \ 'filetypes': ['gitcommit', 'pullrequest']
        \}
endfunction

function! coc#source#conventional_commit#should_complete(opt) abort
  return a:opt.colnr <= 4 && a:opt.linenr == 1
endfunction

function! coc#source#conventional_commit#complete(opt, cb) abort
  let items = ['build: ', 'chore: ', 'ci: ', 'docs: ', 'feat: ', 'fix: ', 'perf: ', 'refactor: ', 'revert: ', 'style: ', 'test: ']
  call a:cb(items)
endfunction

"inoreabbrev <buffer> BB BREAKING CHANGE:

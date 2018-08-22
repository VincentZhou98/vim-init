"======================================================================
"
" init-plugins.vim - 
"
" Created by skywind on 2018/05/31
" Last Modified: 2018/06/10 23:11
"
"======================================================================
" vim: set ts=4 sw=4 tw=78 noet :



"----------------------------------------------------------------------
" 默认情况下的分组，可以再前面覆盖之
"----------------------------------------------------------------------
if !exists('g:bundle_group')
    let g:bundle_group = ['basic', 'tags', 'enhanced', 'filetypes', 'textobj']
    let g:bundle_group += ['tags', 'airline', 'nerdtree', 'ale', 'echodoc', 'grammer']
    let g:bundle_group += ['leaderf']
    let g:bundle_group += ['complete', 'python_doc', 'source_header', 'tex']
    let g:bundle_group += ['markdown']
    let g:bundle_group += ['deoplete']
endif


"----------------------------------------------------------------------
" 计算当前 vim-init 的子路径
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! s:path(path)
    let path = expand(s:home . '/' . a:path )
    return substitute(path, '\\', '/', 'g')
endfunc


"----------------------------------------------------------------------
" 定义一些变量
"----------------------------------------------------------------------
let anaconda_python = $HOME . '/anaconda3/bin/python'

" g:os 已经在init-basic.vim中定义
if g:os == "Darwin"
    let clang_format_exec = '/usr/local/opt/llvm@5/bin/clang-format'
    let gtags_conf = '/usr/local/share/gtags/gtags.conf'
    let ycm_python_interpreter = '/usr/local/bin/python3'
    let ycm_python_binary = anaconda_python
elseif g:os == "Linux"
    let clang_format_exec = 'clang-format'
    let gtags_conf = $HOME . '/.linuxbrew/share/gtags/gtags.conf'
    let ycm_python_interpreter = anaconda_python
    let ycm_python_binary = anaconda_python
endif

"----------------------------------------------------------------------
" 在 ~/.vim/bundles 下安装插件
"----------------------------------------------------------------------
call plug#begin(get(g:, 'bundle_home', '~/.vim/bundles'))


"----------------------------------------------------------------------
" 默认插件 
"----------------------------------------------------------------------

" 全文快速移动，<leader><leader>f{char} 即可触发
Plug 'easymotion/vim-easymotion'

" 文件浏览器，代替 netrw
Plug 'justinmk/vim-dirvish'

" 表格对齐，使用命令 Tabularize
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }

" Diff 增强，支持 histogram / patience 等更科学的 diff 算法
Plug 'chrisbra/vim-diff-enhanced'


"----------------------------------------------------------------------
" Dirvish 设置：自动排序并隐藏文件，同时定位到相关文件
" 这个排序函数可以将目录排在前面，文件排在后面，并且按照字母顺序排序
" 比默认的纯按照字母排序更友好点。
"----------------------------------------------------------------------
function! s:setup_dirvish()
    if &buftype != 'nofile' && &filetype != 'dirvish'
        return
    endif
    if has('nvim')
        return
    endif
    " 取得光标所在行的文本（当前选中的文件名）
    let text = getline('.')
    if ! get(g:, 'dirvish_hide_visible', 0)
        exec 'silent keeppatterns g@\v[\/]\.[^\/]+[\/]?$@d _'
    endif
    " 排序文件名
    exec 'sort ,^.*[\/],'
    let name = '^' . escape(text, '.*[]~\') . '[/*|@=|\\*]\=\%($\|\s\+\)'
    " 定位到之前光标处的文件
    call search(name, 'wc')
    noremap <silent><buffer> ~ :Dirvish ~<cr>
    noremap <buffer> % :e %
endfunc

augroup MyPluginSetup
    autocmd!
    autocmd FileType dirvish call s:setup_dirvish()
augroup END


"----------------------------------------------------------------------
" 基础插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'basic') >= 0

    " 展示开始画面，显示最近编辑过的文件
    Plug 'mhinz/vim-startify'

    " 一次性安装一大堆 colorscheme
    Plug 'flazz/vim-colorschemes'

    "" 我喜欢的主题
    Plug 'morhetz/gruvbox'
    
    " 支持库，给其他插件用的函数库
    Plug 'xolox/vim-misc'

    " 用于在侧边符号栏显示 marks （ma-mz 记录的位置）
    Plug 'kshenoy/vim-signature'

    " 用于在侧边符号栏显示 git/svn 的 diff
    Plug 'mhinz/vim-signify'

    " 根据 quickfix 中匹配到的错误信息，高亮对应文件的错误行
    " 使用 :RemoveErrorMarkers 命令或者 <space>ha 清除错误
    Plug 'mh21/errormarker.vim'

    " 使用 ALT+e 会在不同窗口/标签上显示 A/B/C 等编号，然后字母直接跳转
    Plug 't9md/vim-choosewin'

    " 提供基于 TAGS 的定义预览，函数参数预览，quickfix 预览
    Plug 'skywind3000/vim-preview'

    noremap <m-;> :PreviewTag <cr>
    noremap <m-'> :PreviewClose <cr>
    noremap <m-u> :PreviewScroll -1<cr>
    noremap <m-d> :PreviewScroll +1<cr>
    inoremap <m-u> <c-\><c-o>:PreviewScroll -1<cr>
    inoremap <m-d> <c-\><c-o>:PreviewScroll +1<cr>
    noremap <m-q> :PreviewSignature!<cr>
    inoremap <m-q> <c-\><c-o>:PreviewSignature!<cr>
    autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
    autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>

    " Git 支持
    Plug 'tpope/vim-fugitive'

    " 使用 ALT+E 来选择窗口
    nmap <m-e> <Plug>(choosewin)

    " 默认不显示 startify
    let g:startify_disable_at_vimenter = 0
    let g:startify_session_dir = '~/.vim/session'

    " 使用 <space>ha 清除 errormarker 标注的错误
    noremap <silent><space>ha :RemoveErrorMarkers<cr>

    " signify 调优
    let g:signify_vcs_list = ['git', 'svn']
    let g:signify_sign_add               = '+'
    let g:signify_sign_delete            = '_'
    let g:signify_sign_delete_first_line = '‾'
    let g:signify_sign_change            = '~'
    let g:signify_sign_changedelete      = g:signify_sign_change

    " git 仓库使用 histogram 算法进行 diff
    let g:signify_vcs_cmds = {
            \ 'git': 'git diff --no-color --diff-algorithm=histogram --no-ext-diff -U0 -- %f',
            \}
endif


"----------------------------------------------------------------------
" 增强插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'enhanced') >= 0

    " 用 v 选中一个区域后，ALT_+/- 按分隔符扩大/缩小选区
    Plug 'terryma/vim-expand-region'

    " 快速文件搜索
    Plug 'junegunn/fzf'

    " 给不同语言提供字典补全，插入模式下 c-x c-k 触发
    Plug 'asins/vim-dict'

    " 使用 :FlyGrep 命令进行实时 grep
    Plug 'wsdjeg/FlyGrep.vim'

    " 项目内的搜索替换
    Plug 'brooth/far.vim'

    " 更多的% match跳转
    Plug 'andymass/vim-matchup'

    " 使用 :CtrlSF 命令进行模仿 sublime 的 grep
    Plug 'dyng/ctrlsf.vim'
    " 一些命令
    nmap     <C-F>f <Plug>CtrlSFPrompt
    vmap     <C-F>f <Plug>CtrlSFVwordPath
    vmap     <C-F>F <Plug>CtrlSFVwordExec
    nmap     <C-F>n <Plug>CtrlSFCwordPath
    nmap     <C-F>p <Plug>CtrlSFPwordPath
    nnoremap <C-F>o :CtrlSFOpen<CR>
    nnoremap <C-F>t :CtrlSFToggle<CR>
    inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

    "指定CtrlSF backend，最好是用最快的rg，别用ack
    let g:ctrlsf_ackprg = 'rg'
    
    " 当搜索结束时,focus搜索panel
    let g:ctrlsf_auto_focus = {
    \ "at": "done",
    \ "duration_less_than": 1000
    \ }

    " 异步Grepper
    Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

    " 配对括号和引号自动补全
    Plug 'Raimondi/delimitMate'

    " 提供 gist 接口
    Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
    let g:gista#client#default_username="VincentZhou98"
    
    " ALT_+/- 用于按分隔符扩大缩小 v 选区
    map <m-=> <Plug>(expand_region_expand)
    map <m--> <Plug>(expand_region_shrink)

    "------------------------------------------------------
    " 下面是我的enhanced内容
    "------------------------------------------------------

    " 更好地搜索功能 incsearch.vim
    Plug 'haya14busa/incsearch.vim'
    map /  <Plug>(incsearch-forward)
    map ?  <Plug>(incsearch-backward)
    map g/ <Plug>(incsearch-stay)

    " 进入QuickFix选择
    Plug 'yssl/QFEnter'
    "QFENTER
    let g:qfenter_keymap = {}
    let g:qfenter_keymap.vopen = ['<C-v>']
    let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
    let g:qfenter_keymap.topen = ['<C-t>']

    " 注释插件
    Plug 'tpope/vim-commentary'

    " 多光标移动
    Plug 'terryma/vim-multiple-cursors'

    " 下面的设置为了让YCM不卡
    " vim-multiple-cursors Setup {{{
    function! Multiple_cursors_before()
        call youcompleteme#DisableCursorMovedAutocommands()
    endfunction

    function! Multiple_cursors_after()
        call youcompleteme#EnableCursorMovedAutocommands()
    endfunction
    " }}}


    " 重复vim的动作
    Plug 'tpope/vim-repeat'

    " 与YCM合作，补全函数的所有内容
    Plug 'tenfyzhong/CompleteParameter.vim'
    inoremap <silent><expr> ( complete_parameter#pre_complete("()")
    "Goto next parameter and select it.
    nmap <c-j> <Plug>(complete_parameter#goto_next_parameter)
    imap <c-j> <Plug>(complete_parameter#goto_next_parameter)
    smap <c-j> <Plug>(complete_parameter#goto_next_parameter)
    "Goto previous parameter and select it.
    nmap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
    imap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
    smap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
    "Select next overload function.
    nmap <m-d> <Plug>(complete_parameter#overload_down)
    imap <m-d> <Plug>(complete_parameter#overload_down)
    smap <m-d> <Plug>(complete_parameter#overload_down)
    "Select previous overload function.
    nmap <m-u> <Plug>(complete_parameter#overload_up)
    imap <m-u> <Plug>(complete_parameter#overload_up)
    smap <m-u> <Plug>(complete_parameter#overload_up)
endif


"----------------------------------------------------------------------
" 自动生成 ctags/gtags，并提供自动索引功能
" 不在 git/svn 内的项目，需要在项目根目录 touch 一个空的 .root 文件
" 详细用法见：https://zhuanlan.zhihu.com/p/36279445
"----------------------------------------------------------------------
if index(g:bundle_group, 'tags') >= 0

    " 提供 ctags/gtags 后台数据库自动更新功能
    Plug 'ludovicchabant/vim-gutentags'

    " tag 展示
    Plug 'majutsushi/tagbar'
    nmap <leader>t :TagbarToggle<CR>


    " 提供 GscopeFind 命令并自动处理好 gtags 数据库切换
    " 支持光标移动到符号名上：<leader>cg 查看定义，<leader>cs 查看引用
    Plug 'skywind3000/gutentags_plus'

    let $GTAGSLABEL = 'native-pygments'
    let $GTAGSCONF = gtags_conf

    " Debug调试开启
    let g:gutentags_define_advanced_commands = 1

    " 设定项目目录标志：除了 .git/.svn 外，还有 .root 文件
    let g:gutentags_project_root = ['.root', 'idea']
    let g:gutentags_ctags_tagfile = '.tags'

    " 默认生成的数据文件集中到 ~/.cache/tags 避免污染项目目录，好清理
    let g:gutentags_cache_dir = expand('~/.cache/tags')

    " 默认禁用自动生成
    let g:gutentags_modules = [] 

    " 如果有 ctags 可执行就允许动态生成 ctags 文件
    if executable('ctags')
        let g:gutentags_modules += ['ctags']
    endif

    " 如果有 gtags 可执行就允许动态生成 gtags 数据库
    if executable('gtags') && executable('gtags-cscope')
        let g:gutentags_modules += ['gtags_cscope']
    endif

    " 设置 ctags 的参数
    let g:gutentags_ctags_extra_args = []
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

    " 使用 universal-ctags 的话需要下面这行，请反注释
    let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

    " 禁止 gutentags 自动链接 gtags 数据库
    let g:gutentags_auto_add_gtags_cscope = 0
endif


"----------------------------------------------------------------------
" 文本对象：textobj 全家桶
"----------------------------------------------------------------------
if index(g:bundle_group, 'textobj')
    
    " 基础插件：提供让用户方便的自定义文本对象的接口
    Plug 'kana/vim-textobj-user'

    " indent 文本对象：ii/ai 表示当前缩进，vii 选中当缩进，cii 改写缩进
    Plug 'kana/vim-textobj-indent'

    " 语法文本对象：iy/ay 基于语法的文本对象
    Plug 'kana/vim-textobj-syntax'

    " 函数文本对象：if/af 支持 c/c++/vim/java
    Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }

    " 参数文本对象：i,/a, 包括参数或者列表元素
    Plug 'sgur/vim-textobj-parameter'

    " 提供 python 相关文本对象，if/af 表示函数，ic/ac 表示类
    Plug 'bps/vim-textobj-python', {'for': 'python'}

    " 提供 uri/url 的文本对象，iu/au 表示
    Plug 'jceb/vim-textobj-uri'
endif


"----------------------------------------------------------------------
" 文件类型扩展
"----------------------------------------------------------------------
if index(g:bundle_group, 'filetypes') >= 0

    " powershell 脚本文件的语法高亮
    Plug 'pprovost/vim-ps1', { 'for': 'ps1' }

    " lua 语法高亮增强
    Plug 'tbastos/vim-lua', { 'for': 'lua' }

    " C++ 语法高亮增强，支持 11/14/17 标准
    Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }

    " 额外语法文件
    Plug 'justinmk/vim-syntax-extra', { 'for': ['c', 'bison', 'flex', 'cpp'] }
    Plug 'sheerun/vim-polyglot'
    " polyglot很容易产生奇怪的冲突，把相关的禁止
    " 比如init-keymaps 里面的grep，非常奇怪
    let g:polyglot_disabled = ['python', 'python-compiler', 'python-ident', "c++11"]

    " python 语法文件增强
    Plug 'vim-python/python-syntax', { 'for': ['python'] }

    " rust 语法增强
    Plug 'rust-lang/rust.vim', { 'for': 'rust' }

    " vim org-mode 
    Plug 'jceb/vim-orgmode', { 'for': 'org' }
    noremap glf @<Plug>OrgHyperlinkFollow 
    " 这个remap永远不成功，不知道怎么搞
    noremap <c-h> @<Plug>OrgNewHeadingBelowAfterChildrenNormal
    let g:org_export_init_script=expand("~/.spacemacs")
    if g:os == "Darwin"
        let g:org_export_emacs="/usr/local/bin/emacs"
    elseif g:os == "Linux"
        let g:org_export_emacs="~/.linuxbrew/bin/emacs"
    endif
    let g:org_agenda_files=['~/.org/index.org']
 

    " Vasp相关
    Plug 'alejandrogallo/vasp.vim'

    " Julia相关
    Plug 'JuliaEditorSupport/julia-vim'
    let g:default_julia_version = '0.6'

    " lammps 相关
    au  BufNewFile,BufReadPost *.lmp so ~/.vim/vim-init/syntax/lammps.vim
    au  BufNewFile,BufReadPost in.* so ~/.vim/vim-init/syntax/lammps.vim
endif


"----------------------------------------------------------------------
" airline
"----------------------------------------------------------------------
if index(g:bundle_group, 'airline') >= 0
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    " let g:airline_powerline_fonts = 0
    let g:airline_exclude_preview = 1
    let g:airline_section_b = '%n'
    let g:airline_theme='deus'
    let g:airline#extensions#branch#enabled = 0
    let g:airline#extensions#syntastic#enabled = 0
    let g:airline#extensions#fugitiveline#enabled = 0
    let g:airline#extensions#csv#enabled = 0
    let g:airline#extensions#vimagit#enabled = 0
endif


"----------------------------------------------------------------------
" NERDTree
"----------------------------------------------------------------------
if index(g:bundle_group, 'nerdtree') >= 0
    Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFocus', 'NERDTreeToggle', 'NERDTreeCWD', 'NERDTreeFind'] }
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeDirArrows = 1
    let g:NERDTreeHijackNetrw = 0
    noremap <space>nn :NERDTree<cr>
    noremap <space>nn :NERDTreeFind<cr>
    noremap <space>no :NERDTreeFocus<cr>
    noremap <space>nm :NERDTreeMirror<cr>
    noremap <space>nt :NERDTreeToggle<cr>
endif


"----------------------------------------------------------------------
" LanguageTool 语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'grammer') >= 0
    Plug 'rhysd/vim-grammarous'
    noremap <space>rg :GrammarousCheck --lang=en-US --no-move-to-first-error --no-preview<cr>
    map <space>rr <Plug>(grammarous-open-info-window)
    map <space>rv <Plug>(grammarous-move-to-info-window)
    map <space>rs <Plug>(grammarous-reset)
    map <space>rx <Plug>(grammarous-close-info-window)
    map <space>rm <Plug>(grammarous-remove-error)
    map <space>rd <Plug>(grammarous-disable-rule)
    map <space>rn <Plug>(grammarous-move-to-next-error)
    map <space>rp <Plug>(grammarous-move-to-previous-error)
endif


"----------------------------------------------------------------------
" ale：动态语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'ale') >= 0
    Plug 'w0rp/ale'

    " 设定延迟和提示信息
    let g:ale_completion_delay = 500
    let g:ale_echo_delay = 20
    let g:ale_lint_delay = 500
    let g:ale_echo_msg_format = '[%linter%] %code: %%s'

    " 设定检测的时机：normal 模式文字改变，或者离开 insert模式
    " 禁用默认 INSERT 模式下改变文字也触发的设置，太频繁外，还会让补全窗闪烁
    let g:ale_lint_on_text_changed = 'normal'
    let g:ale_lint_on_insert_leave = 1

    " 在 linux/mac 下降低语法检查程序的进程优先级（不要卡到前台进程）
    if has('win32') == 0 && has('win64') == 0 && has('win32unix') == 0
        let g:ale_command_wrapper = 'nice -n5'
    endif

    " 允许 airline 集成
    let g:airline#extensions#ale#enabled = 1

    " ALEFix 快捷键
    " 相应的YCM也有一个fix
    nmap <leader>f <Plug>(ale_fix)

    " 编辑不同文件类型需要的语法检查器
    let g:ale_linters = {
                \ 'c': ['gcc', 'cppcheck', 'cquery'], 
                \ 'cpp': ['gcc', 'cppcheck', 'cquery'], 
                \ 'python': ['flake8', 'pylint', 'mypy', 'McCabe'], 
                \ 'lua': ['luac'], 
                \ 'go': ['go build', 'gofmt'],
                \ 'java': ['javac'],
                \ 'javascript': ['eslint'], 
                \ }


    " 获取 pylint, flake8 的配置文件，在 vim-init/tools/conf 下面
    function s:lintcfg(name)
        let conf = s:path('tools/conf/')
        let path1 = conf . a:name
        let path2 = expand('~/.vim/linter/'. a:name)
        if filereadable(path2)
            return path2
        endif
        return shellescape(filereadable(path2)? path2 : path1)
    endfunc

    " 设置 flake8/pylint 的参数
    let g:ale_python_flake8_options = '--conf='.s:lintcfg('flake8.conf')
    let g:ale_python_pylint_options = '--rcfile='.s:lintcfg('pylint.conf')
    let g:ale_python_pylint_options .= ' --disable=W'
    let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
    let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
    let g:ale_c_cppcheck_options = ''
    let g:ale_cpp_cppcheck_options = ''


    let g:ale_python_mypy_options = '--python-executable /home/tgzhou/anaconda3/bin/python'
    let g:ale_cpp_clangcheck_options = '-extra-arg=-std=c++14'
    let g:ale_cpp_clangtidy_options = '-extra-arg=-std=c++14'
    " let g:ale_cpp_clangtidy_executable = ''
    " let g:ale_cpp_clangcheck_executable = ''
    " let g:ale_cpp_clangformat_options = "-style='{BasedOnStyle: LLVM, IndentWidth: 4}'"  " Now I use 2 as default cpp indent
    " let g:ale_c_clangformat_options = "-style='{BasedOnStyle: LLVM, IndentWidth: 4}'"  "Now I use 2 as default c indent
    let g:ale_python_mypy_options = '--ignore-missing-imports --follow-imports=skip'
    let g:ale_fixers = { 
                \ 'python': ['yapf', 'isort'],
                \ 'cpp': ['clang-format'],
                \ 'c': ['clang-format'],
                \ 'sh': ['shfmt']
                \}
    let g:ale_cpp_clangformat_executable = clang_format_exec
    let g:ale_c_clangformat_executable = clang_format_exec
    let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
    let g:ale_cpp_clang_options = '-Wall -O2 -std=c++14'
    let g:ale_c_cppcheck_options = '--enable=all --inconclusive --std=c11'
    let g:ale_cpp_cppcheck_options = '--enable=all --inconclusive --std=c++14'

    let g:ale_linters.text = ['textlint', 'write-good', 'languagetool']

    " 如果没有 gcc 只有 clang 时（FreeBSD）
    if executable('gcc') == 0 && executable('clang')
        let g:ale_linters.c += ['clang']
        let g:ale_linters.cpp += ['clang']
    endif
endif

"----------------------------------------------------------------------
" LSP补全与分析 
"----------------------------------------------------------------------
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }


let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
if g:os == "Darwin"
    let g:LanguageClient_settingsPath = expand('~/.vim/vim-init/tools/conf/languageclient_mac.json')
elseif g:os == "Linux"
    let g:LanguageClient_settingsPath = expand('~/.vim/vim-init/tools/conf/languageclient_linux.json')
endif
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
" let g:LanguageClient_hoverPreview = 'Never'

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'python': ['pyls'],
    \ 'c': ['cquery'],
    \ 'cpp': ['cquery'],
    \ 'julia': ['julia', '--startup-file=no', '--history-file=no', '-e', '
    \    using LanguageServer;
    \    server = LanguageServer.LanguageServerInstance(STDIN, STDOUT, false);
    \    server.runlinter = true;
    \    run(server);
    \'],
\ }

" Or map each action separately
noremap <leader>rd :call LanguageClient#textDocument_definition()<cr>
noremap <leader>rr :call LanguageClient#textDocument_references()<cr>
noremap <leader>rh :call LanguageClient#textDocument_hover()<cr>
nnoremap <silent> <leader>rn :call LanguageClient#textDocument_rename()<CR>
nnoremap <leader>rm :call LanguageClient_contextMenu()<CR>

"----------------------------------------------------------------------
" deoplete搭配LanguageClient使用
"----------------------------------------------------------------------
if index(g:bundle_group, 'deoplete') >= 0
    if has('nvim')
      Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
      Plug 'Shougo/deoplete.nvim'
      Plug 'roxma/nvim-yarp'
      Plug 'roxma/vim-hug-neovim-rpc'
    endif
    " Not auto start due to powerful YCM
    " let g:deoplete#enable_at_startup = 1
endif

"----------------------------------------------------------------------
" echodoc：搭配 YCM/deoplete 在底部显示函数参数
"----------------------------------------------------------------------
if index(g:bundle_group, 'echodoc') >= 0
    Plug 'Shougo/echodoc.vim'
    set noshowmode
    let g:echodoc#enable_at_startup = 1
endif


"----------------------------------------------------------------------
" LeaderF：CtrlP / FZF 的超级代替者，文件模糊匹配，tags/函数名 选择
"----------------------------------------------------------------------
if index(g:bundle_group, 'leaderf') >= 0
    " 如果 vim 支持 python 则启用  Leaderf
    if has('python') || has('python3')
        Plug 'Yggdroot/LeaderF'

        " CTRL+p 打开文件模糊匹配
        let g:Lf_ShortcutF = '<c-p>'

        " ALT+n 打开 buffer 模糊匹配
        let g:Lf_ShortcutB = '<m-n>'

        " CTRL+m 打开最近使用的文件 MRU，进行模糊匹配
        noremap <c-m> :LeaderfMru<cr>

        " ALT+p 打开函数列表，按 i 进入模糊匹配，ESC 退出
        noremap <m-p> :LeaderfFunction!<cr>

        " ALT+SHIFT+p 打开 tag 列表，i 进入模糊匹配，ESC退出
        noremap <m-P> :LeaderfBufTag!<cr>

        " ALT+b 打开 buffer 列表进行模糊匹配
        noremap <m-b> :LeaderfBuffer<cr>

        " 全局 tags 模糊匹配
        noremap <m-m> :LeaderfTag<cr>

        " 最大历史文件保存 2048 个
        let g:Lf_MruMaxFiles = 2048

        " ui 定制
        let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

        " 如何识别项目目录，从当前文件目录向父目录递归知道碰到下面的文件/目录
        let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
        let g:Lf_WorkingDirectoryMode = 'Ac'
        let g:Lf_WindowHeight = 0.30
        let g:Lf_CacheDirectory = expand('~/.vim/cache')

        " 显示绝对路径
        let g:Lf_ShowRelativePath = 0

        " 隐藏帮助
        let g:Lf_HideHelp = 1

        " 模糊匹配忽略扩展名
        let g:Lf_WildIgnore = {
                    \ 'dir': ['.svn','.git','.hg'],
                    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
                    \ }

        " MRU 文件忽略扩展名
        let g:Lf_MruFileExclude = ['*.so', '*.exe', '*.py[co]', '*.sw?', '~$*', '*.bak', '*.tmp', '*.dll']
        let g:Lf_StlColorscheme = 'powerline'

        " 禁用 function/buftag 的预览功能，可以手动用 p 预览
        let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

        " 使用 ESC 键可以直接退出 leaderf 的 normal 模式
        let g:Lf_NormalMap = {
                \ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
                \ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<cr>']],
                \ "Mru": [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<cr>']],
                \ "Tag": [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<cr>']],
                \ "BufTag": [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<cr>']],
                \ "Function": [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<cr>']],
                \ }

    else
        " 不支持 python ，使用 CtrlP 代替
        Plug 'ctrlpvim/ctrlp.vim'

        " 显示函数列表的扩展插件
        Plug 'tacahiroy/ctrlp-funky'

        " 忽略默认键位
        let g:ctrlp_map = ''

        " 模糊匹配忽略
        let g:ctrlp_custom_ignore = {
          \ 'dir':  '\v[\/]\.(git|hg|svn)$',
          \ 'file': '\v\.(exe|so|dll|mp3|wav|sdf|suo|mht)$',
          \ 'link': 'some_bad_symbolic_links',
          \ }

        " 项目标志
        let g:ctrlp_root_markers = ['.project', '.root', '.svn', '.git']
        let g:ctrlp_working_path = 0

        " CTRL+p 打开文件模糊匹配
        noremap <c-p> :CtrlP<cr>

        " CTRL+m 打开最近访问过的文件的匹配
        noremap <c-m> :CtrlPMRUFiles<cr>

        " ALT+p 显示当前文件的函数列表
        noremap <m-p> :CtrlPFunky<cr>

        " ALT+n 匹配 buffer
        noremap <m-n> :CtrlPBuffer<cr>
    endif
endif


"----------------------------------------------------------------------
" markdown写作插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'markdown') >= 0
    " vim-markdonw-composer
    function! BuildComposer(info)
      if a:info.status != 'unchanged' || a:info.force
        if has('nvim')
          !cargo build --release
        else
          !cargo build --release --no-default-features --features json-rpc
        endif
      endif
    endfunction
    Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }
endif

"------------------------------------------------------
" 补全插件
"------------------------------------------------------
if index(g:bundle_group, 'complete') >= 0
    " 安装YCM
    Plug 'Valloric/YouCompleteMe'

    " 生成项目的配置文件
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}

    " vim 代码片段
    " supertab 可以与ycm共同合作
    " Plug 'ervandew/supertab' 
    Plug 'honza/vim-snippets'
    Plug 'SirVer/ultisnips'

    "Ultisnips YCM
    " make YCM compatible with UltiSnips (using supertab)
    let g:ycm_key_list_select_completion             = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion           = ['<C-p>', '<Up>']
    " let g:SuperTabDefaultCompletionType            = '<C-n>'
    " better key bindings for UltiSnipsExpandTrigger
    let g:UltiSnipsExpandTrigger                     = "<tab>"
    let g:UltiSnipsListSnippets                      = "<c-s>"
    let g:UltiSnipsEditSplit                         = "vertical"
    let g:UltiSnipsSnippetsDir                       = expand("~/.vim/vim-init/tools/conf/my_snippets")
    " Already have vim-snippest Ultisnips directory
    let g:UltiSnipsSnippetDirectories                = ['UltiSnips', expand("~/.vim/vim-init/tools/conf/my_snippets")]
endif


"------------------------------------------------------
" Python文档功能增强插件相关
"------------------------------------------------------
if index(g:bundle_group, 'python_doc') >= 0
    Plug 'heavenshell/vim-pydocstring'
    " Plug 'sillybun/vim-autodoc'
endif

"------------------------------------------------------
" repl 功能 现在不太好用
"------------------------------------------------------
if index(g:bundle_group, 'repl') >= 0
    "PERL vim 
    Plug 'sillybun/vim-repl'
    nnoremap <leader>r :REPLToggle<Cr>
    let g:sendtorepl_invoke_key = "<leader>w"
    let g:repl_program = {
        \    "python": $anaconda_python,
        \    "gnuplot": "gnuplot",
        \    "matlab": "matlab -nodesktop -nosplash",
        \    "cpp.root": "root -l",
        \    "cpp": "cling -std=c++14",
        \    "mma": "MathematicaScript",
        \    "zsh": "zsh",
        \    "default": "bash",
        \    }  
    " root -l close splash window and work with stdin 
    let g:repl_height = 15
    let g:repl_width = 30
    let g:repl_position = 3 
    let g:repl_exit_commands = {
                \    $anaconda_python: "exit()",
                \    "bash": "exit",
                \    "root": ".q",
                \    "zsh": "exit",
                \    "default": "exit",
                \    }
endif


"------------------------------------------------------
" 源文件头文件跳转
"------------------------------------------------------
if index(g:bundle_group, 'source_header') >= 0
    Plug 'ericcurtin/CurtineIncSw.vim'
    map <leader>sh :call CurtineIncSw()<CR>
endif


"----------------------------------------------------------------------
" vim tex写作
"----------------------------------------------------------------------
if index(g:bundle_group, 'tex') >= 0
    " vimtex 折叠很方便
    Plug 'Konfekt/FastFold'

    Plug 'lervag/vimtex'
    "Fold, integrate with fastfold plugin
    let g:vimtex_fold_enabled = 1
    let g:vimtex_quickfix_enabled = 0
    let g:vimtex_view_method = 'skim'
    "********************************************************
    "注意！！！！！！！！！！！
    "这里设置了没有用，要在~/.latexmkrc 里面设置才有用
    "经验!!!!!!!!!!!!!!!!!!!!!!
    "因此可以用<leader>ll 来操作，自动刷新latex编译
    let g:vimtex_latexmk_options = '-pdf -pdflatex="xelatex --shell-escape %O %S " -verbose -file-line-error -synctex=1 -interaction=nonstopmode'

    " 打开pdf预览
    map ,r :w<CR>:silent !/Applications/Skim.app/Contents/SharedSupport/displayline <C-r>=line('.')<CR> %<.pdf<CR>

    if has('nvim')
        let g:vimtex_compiler_progname = 'nvr'
    endif

endif


"----------------------------------------------------------------------
" vim tex写作
"----------------------------------------------------------------------
if index(g:bundle_group, 'icons') >= 0
    Plug 'ryanoasis/vim-devicons'
    let g:airline_powerline_fonts = 1
endif

"----------------------------------------------------------------------
" 结束插件安装
"----------------------------------------------------------------------
call plug#end()



"----------------------------------------------------------------------
" YouCompleteMe 默认设置：YCM 需要你另外手动编译安装
"----------------------------------------------------------------------

" 禁用预览功能：扰乱视听
let g:ycm_add_preview_to_completeopt = 0

" 禁用诊断功能：我们用前面更好用的 ALE 代替
let g:ycm_python_binary_path = ycm_python_binary 
let g:ycm_server_python_interpreter = ycm_python_interpreter
let g:ycm_global_ycm_extra_conf = expand('~/.vim/vim-init/tools/conf/ycm_extra_conf.py')
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-space>'
set completeopt=menu,menuone

" noremap <c-z> <NOP>

" 保留几个好用的跳转
nnoremap <leader>gg :YcmCompleter GoTo<CR>
nnoremap <leader>gf :YcmCompleter FixIt<CR>
"nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <leader>gt :YcmCompleter GetType<CR>
nnoremap <leader>gdc :YcmCompleter GetDoc<CR>

" 两个字符自动触发语义补全
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ 'tex': g:vimtex#re#youcompleteme,
            \ }


" YCM tex 补全
" if !exists('g:ycm_semantic_triggers')
"     let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme
" endif

"----------------------------------------------------------------------
" Ycm 白名单（非名单内文件不启用 YCM），避免打开个 1MB 的 txt 分析半天
"----------------------------------------------------------------------
let g:ycm_filetype_whitelist = { 
            \ "c":1,
            \ "cpp":1, 
            \ "objc":1,
            \ "objcpp":1,
            \ "python":1,
            \ "java":1,
            \ "javascript":1,
            \ "coffee":1,
            \ "vim":1, 
            \ "go":1,
            \ "cs":1,
            \ "lua":1,
            \ "perl":1,
            \ "perl6":1,
            \ "php":1,
            \ "ruby":1,
            \ "rust":1,
            \ "tex":1,
            \ "erlang":1,
            \ "asm":1,
            \ "nasm":1,
            \ "masm":1,
            \ "tasm":1,
            \ "asm68k":1,
            \ "asmh8300":1,
            \ "asciidoc":1,
            \ "basic":1,
            \ "vb":1,
            \ "make":1,
            \ "cmake":1,
            \ "html":1,
            \ "css":1,
            \ "less":1,
            \ "json":1,
            \ "cson":1,
            \ "typedscript":1,
            \ "haskell":1,
            \ "lhaskell":1,
            \ "lisp":1,
            \ "scheme":1,
            \ "sdl":1,
            \ "sh":1,
            \ "zsh":1,
            \ "bash":1,
            \ "man":1,
            \ "markdown":1,
            \ "matlab":1,
            \ "maxima":1,
            \ "dosini":1,
            \ "conf":1,
            \ "config":1,
            \ "zimbu":1,
            \ "ps1":1,
            \ "julia":1,
            \ "incar":1,
            \ "poscar":1,
            \ "lammps":1,
            \ }



Skip to content
DEV Community
Search...

Log in
Create account

7

1

6

Heiker
Heiker
Posted on Aug 4, 2021 • Updated on Nov 1, 2021

Neovim: using vim-plug in lua
#
neovim
#
shell
Recently I migrated my neovim configuration from vimscript to lua and in the process I learned a few things about neovim's lua api. One cool thing about it is that we can use "vim functions" inside lua, and what's even better this integration is good enough to bring vim-plug (a popular plugin manager) into lua. I'm going to show two ways you can use vim-plug inside your lua configuration.

How does it work?
There are two ways we can call "vim functions" in lua, using vim.fn or vim.call.

vim.fn
This one is a meta-table, a special object that defines its own behavior for common operations. What it does is provide a convenient syntax to call functions.
vim.fn.has('nvim-0.5')
vim.call
Is a function we can use to call vim functions.
vim.call('has', 'nvim-0.5')
What's the difference?

Just details. Basically those two examples that I showed you have the same exact effect. The difference is that you can store vim.fn.has in another variable, and vim.call('has') will just call has with no arguments.

Now that we know what's at the heart of this "trick" let's get down to business.

Look ma, no vimscript
In vim-plug's documentation we can find something like this.
call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-sensible'

call plug#end()
In here they are calling two vim functions and one command. We know how to call those functions in lua.
vim.call('plug#begin', '~/.config/nvim/plugged')

-- what about Plug?...

vim.call('plug#end')
What about Plug? It turns out Plug is a command that calls a function, check it out. So the thing that does the heavy lifting is plug#. With this knowledge and some lua sourcery we can complete our example.
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'tpope/vim-sensible'

vim.call('plug#end')
Isn't that beautiful? Don't relax just yet, the story doesn't end there.

That is one way to call Plug and it works just fine, but sometimes we need to pass a second argument. In vimscript it looks like this.
Plug 'scrooloose/nerdtree', {'on':  'NERDTreeToggle'}
The lua equivalent is not that different but is enough to prevent a clean copy/paste. Anyway, we need to this.
Plug('scrooloose/nerdtree', {on = 'NERDTreeToggle'})
Now the parenthesis are mandatory. The second argument is a lua table, notice that instead of : we use =.

If you need to pass a list you need to use a table too.
Plug('scrooloose/nerdtree', {on = {'NERDTreeToggle', 'NERDTree'})
Here comes little bit of bad news. Plug has a couple of options that can cause an error, for and do. Those two are reserved keywords so we need use a different syntax when we use them.
Plug('junegunn/goyo.vim', {['for'] = 'markdown'})
We have to wrap it in quotes and square brackets.

Now do is an interesting one. It takes a string or a function, and what's interesting is that we can give it a vim function or a lua function.
Plug('junegunn/fzf', {['do'] = vim.fn['fzf#install']})
This also works.
Plug('junegunn/fzf', {
  ['do'] = function()
    vim.call('fzf#install')
  end
})
Lua interface
Just in case you're not a fan vim.fn/vim.call let me show you a little "lua interface" that I wrote.
local configs = {
  lazy = {},
  start = {}
}

local Plug = {
  begin = vim.fn['plug#begin'],

  -- "end" is a keyword, need something else
  ends = function()
    vim.fn['plug#end']()

    for i, config in pairs(configs.start) do
      config()
    end
  end
}

-- Not a fan of global functions, but it'll work better 
-- for the people that will copy/paste this
_G.VimPlugApplyConfig = function(plugin_name)
  local fn = configs.lazy[plugin_name]
  if type(fn) == 'function' then fn() end
end

local plug_name = function(repo)
  return repo:match("^[%w-]+/([%w-_.]+)$")
end

-- "Meta-functions"
local meta = {

  -- Function call "operation"
  __call = function(self, repo, opts)
    opts = opts or vim.empty_dict()

    -- we declare some aliases for `do` and `for`
    opts['do'] = opts.run
    opts.run = nil

    opts['for'] = opts.ft
    opts.ft = nil

    vim.call('plug#', repo, opts)

    -- Add basic support to colocate plugin config
    if type(opts.config) == 'function' then
      local plugin = opts.as or plug_name(repo)

      if opts['for'] == nil and opts.on == nil then
        configs.start[plugin] = opts.config
      else
        configs.lazy[plugin] = opts.config

        local user_cmd = [[ autocmd! User %s ++once lua VimPlugApplyConfig('%s') ]]
        vim.cmd(user_cmd:format(plugin, plugin))
      end

    end
  end
}

-- Meta-tables are awesome
return setmetatable(Plug, meta)
Let's pretend we have that code in ~/.config/nvim/lua/usermod/vimplug.lua, this is how we use it.
local Plug = require 'usermod.vimplug'

Plug.begin('~/.config/nvim/plugged')

Plug 'moll/vim-bbye'
Plug('junegunn/goyo.vim', {ft = 'markdown'})
Plug('VonHeikemen/rubber-themes.vim', {
  run = function()
    vim.opt.termguicolors = true
    vim.cmd('colorscheme rubber')
  end
})
Plug('b3nj5m1n/kommentary', {
  config = function()
    local cfg = require('kommentary.config')

    cfg.configure_language('default', {
      prefer_single_line_comments = true,
    })
  end
})

Plug.ends()
Isn't that just slightly better? I think so.

UPDATE 2021-10-02:

Notice how the last plugin (b3nj5m1n/kommentary) has a config option. I've added this feature so you can put the config for your plugin all in one place.

I've only made some trivial test with this, which seems to work. I don't use vim-plug anymore so let me know in the comments if something doesn't work.

Conclusion
We learned about vim.fn and vim.call, how we can use it to our advantage and bring vim-plug into lua. We now we can use it without anything but the built-in lua api. And as a special bonus we figure out how to create a little wrapper that makes it look better.

Thank you for your time. If you find this article useful and want to support my efforts, consider leaving a tip in buy me a coffee ☕.

buy me a coffee

Discussion (1)
Subscribe
pic
Add to the discussion
 
musale profile image
Musale Martin
•
Nov 23 '21

This is so succint!


1
 like
Reply
Code of Conduct • Report abuse
Read next
0xbf profile image
Copy file content to clipboard in terminal
Boo - Apr 19 '20

iggredible profile image
How to use Vim Packages
Igor Irianto - Apr 14 '20

aagamezl profile image
Changing the GNOME Shell login background
aagamezl - Apr 13 '20

techwatching profile image
Clean up your local git branches.
Alexandre - Apr 6 '20


Heiker
Follow
Web developer from Venezuela. I like solving problems. Currently trying to improve my communication skills
JOINED
Apr 2, 2018
More from Heiker
Navigate your command history with ease
#shell #beginners
Navega a través del historial de comandos de una manera eficiente
#shell #beginners #spanish
Want to use env variables in that config file? Well, you can... kind of
#shell #todayilearned
local configs = {
  lazy = {},
  start = {}
}

local Plug = {
  begin = vim.fn['plug#begin'],

  -- "end" is a keyword, need something else
  ends = function()
    vim.fn['plug#end']()

    for i, config in pairs(configs.start) do
      config()
    end
  end
}

-- Not a fan of global functions, but it'll work better 
-- for the people that will copy/paste this
_G.VimPlugApplyConfig = function(plugin_name)
  local fn = configs.lazy[plugin_name]
  if type(fn) == 'function' then fn() end
end

local plug_name = function(repo)
  return repo:match("^[%w-]+/([%w-_.]+)$")
end

-- "Meta-functions"
local meta = {

  -- Function call "operation"
  __call = function(self, repo, opts)
    opts = opts or vim.empty_dict()

    -- we declare some aliases for `do` and `for`
    opts['do'] = opts.run
    opts.run = nil

    opts['for'] = opts.ft
    opts.ft = nil

    vim.call('plug#', repo, opts)

    -- Add basic support to colocate plugin config
    if type(opts.config) == 'function' then
      local plugin = opts.as or plug_name(repo)

      if opts['for'] == nil and opts.on == nil then
        configs.start[plugin] = opts.config
      else
        configs.lazy[plugin] = opts.config

        local user_cmd = [[ autocmd! User %s ++once lua VimPlugApplyConfig('%s') ]]
        vim.cmd(user_cmd:format(plugin, plugin))
      end

    end
  end
}

-- Meta-tables are awesome
return setmetatable(Plug, meta)
DEV Community — A constructive and inclusive social network for software developers. With you every step of your journey.

Built on Forem — the open source software that powers DEV and other inclusive communities.

Made with love and Ruby on Rails. DEV Community © 2016 - 2022.
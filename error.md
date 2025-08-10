Error detected while processing BufWritePre Autocommands for "*"..BufWritePre Autocommands for "*":                                                                     
Error executing lua callback: ....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:270: The nested {} syntax to run the first formatter has been replaced by the 
stop_after_first option (see :help conform.format).                                                                                                                     
stack traceback:                                                                                                                                                        
        [C]: in function 'assert'                                                                                                                                       
        ....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:270: in function 'dedupe_formatters'                                                                
        ....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:293: in function 'list_formatters_for_buffer'                                                       
        ....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:461: in function 'format'                                                                           
        ....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:113: in function <....local/share/nvim/lazy/conform.nvim/lua/conform/init.lua:98>                   
        [C]: in function 'nvim_exec_autocmds'                                                                                                                           
        ...hare/nvim/lazy/lazy.nvim/lua/lazy/core/handler/event.lua:161: in function <...hare/nvim/lazy/lazy.nvim/lua/lazy/core/handler/event.lua:160>                  
        [C]: in function 'xpcall'                                                                                                                                       
        .../.local/share/nvim/lazy/lazy.nvim/lua/lazy/core/util.lua:135: in function 'try'                                                                              
        ...hare/nvim/lazy/lazy.nvim/lua/lazy/core/handler/event.lua:160: in function '_trigger'                                                                         
        ...hare/nvim/lazy/lazy.nvim/lua/lazy/core/handler/event.lua:143: in function 'trigger'

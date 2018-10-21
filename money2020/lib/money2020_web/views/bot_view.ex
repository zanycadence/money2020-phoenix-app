defmodule Money2020Web.BotView do
    use Money2020Web, :view

    def help_overview() do
        """
        Use one of the available commands
        listed below and replace the place holders
        with your information
        """
    end

    def help_commands() do
"
pay
to: {recipient nickname}
amount: {in us dollars}

register
full name: {}
card number: {}
"
    end
end
# -*- coding: utf-8 -*-

require "nokogiri"
require "open-uri"

Plugin.create(:scrap_47_news) do
    ELEMENT_TITLE = '#bt_title'
    ELEMENTS_BODY = ['span#bt_body p']

    filter_rebuild_message do |message|
        dummy_message = message
        if message.user === '47news' then
            begin
                dummy_text = get_contents(message)
                dummy_message = Message.new(
                    :id => message[:id],
                    :message => dummy_text,
                    :user => message[:user],
                    :receiver => message[:receiver],
                    :replyto => message[:replyto],
                    :source => message[:source],
                    :geo => message[:geo],
                    :exact => message[:exact],
                    :created => message[:created],
                    :modified => message[:modified],
                    :system => true)
            rescue => e
                p e.backtrace.join("\n")
            end
        end
        [dummy_message]
    end

    # コンテンツ抽出と
    # メッセージ詰め込み
    def get_contents(message)
        url = URI.extract(message.to_s)[0]
        doc = Nokogiri::HTML(open(url))

        text = "■ #{doc.css(ELEMENT_TITLE)[0].text}\n"

        for message_selector in ELEMENTS_BODY do
            elements = doc.css(message_selector)

            # 取得した要素に応じてテキスト変換
            for element in elements do
                text += "#{element.text}\n"
            end
        end

        return text
    end
end

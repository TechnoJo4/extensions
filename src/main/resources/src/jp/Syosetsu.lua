-- {"id":3,"version":"1.2.0","author":"Doomsdayrs","repo":""}

local baseURL = "https://yomou.syosetu.com"
local passageURL = "https://ncode.syosetu.com"

return {
	id = 3,
	name = "Syosetsu",
	baseURL = baseURL,
	imageURL = "https://static.syosetu.com/view/images/common/logo_yomou.png",
	listings = {
		Listing("Latest", {}, true, function(data, page)
			if page == 0 then page = 1 end
			return map(GETDocument(baseURL .. "/search.php?&search_type=novel&order_former=search&order=new&notnizi=1&p=" .. page):select("div.searchkekka_box"), function(v)
				local novel = Novel()
				local e = v:selectFirst("div.novel_h"):selectFirst("a.tl")
				novel:setLink(e:attr("href"))
				novel:setTitle(e:text())
				return novel
			end)
		end)
	},

	getPassage = function(chapterURL)
		return table.concat(map(GETDocument(chapterURL):selectFirst("div#novel_contents"):select("p"), function(v)
			return v:text()
		end), "\n")
	end,

	parseNovel = function(novelURL, loadChapters)
		local novelPage = NovelInfo()
		local document = GETDocument(novelURL)

		novelPage:setAuthors({ document:selectFirst("div.novel_writername"):text():gsub("作者：", "") })
		novelPage:setTitle(document:selectFirst("p.novel_title"):text())

		-- Description
		novelPage:setDescription(document:selectFirst("div#novel_color"):text())

		-- Chapters
		if loadChapters then
			novelPage:setChapters(AsList(map(document:select("dl.novel_sublist2"), function(v, i)
				local chap = NovelChapter()
				chap:setTitle(v:selectFirst("a"):text())
				chap:setLink(passageURL .. v:selectFirst("a"):attr("href"))
				chap:setRelease(v:selectFirst("dt.long_update"):text())
				chap:setOrder(i)
				return chap
			end)))
		end
		return novelPage
	end,

	search = function(data)
		return map(GETDocument(baseURL .. "/search.php?&word=" .. data[0]:gsub("%+", "%2"):gsub(" ", "\\+")):select("div.searchkekka_box"), function(v)
			local novel = Novel()
			local e = v:selectFirst("div.novel_h"):selectFirst("a.tl")
			novel:setLink(e:attr("href"))
			novel:setTitle(e:text())
			return novel
		end)
	end,

	updateSetting = function()end
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> extractJSONContent(Map<String, dynamic> selfExtractConfig, String jsonResponse) async {
  print("开始 JSON 提取");

  final config = selfExtractConfig["site2"];
  final type = config["type"];
  final pathToTitle = config["path_to_title"].split('.');
  final pathToContent = config["path_to_content"].split('.');
  final defaultContent = config["default_content"];

  if (type != "json") {
    throw Exception("Unsupported type: $type");
  }

  dynamic jsonData;
  try {
    jsonData = jsonDecode(jsonResponse);
  } catch (e) {
    throw FormatException("Invalid JSON format: $e");
  }

  dynamic extractedContent = jsonData;
  dynamic extractedTitle = jsonData;

  try {
    for (final key in pathToTitle) {
      if (key.contains('[') && key.contains(']')) {
        // 处理数组索引
        final parts = key.split(RegExp(r'\[|\]'));
        final arrayKey = parts[0];
        final index = int.parse(parts[1]);
        extractedTitle = extractedTitle[arrayKey][index];
      } else {
        extractedTitle = extractedTitle[key];
      }

      if (extractedTitle == null) {
        extractedTitle = defaultContent;
        break;
      }
    }
  } catch (e) {
    extractedTitle = defaultContent;
  }

  try {
    for (final key in pathToContent) {
      if (key.contains('[') && key.contains(']')) {
        // 处理数组索引
        final parts = key.split(RegExp(r'\[|\]'));
        final arrayKey = parts[0];
        final index = int.parse(parts[1]);
        extractedContent = extractedContent[arrayKey][index];
      } else {
        extractedContent = extractedContent[key];
      }

      if (extractedContent == null) {
        extractedContent = defaultContent;
        break;
      }
    }
  } catch (e) {
    extractedContent = defaultContent;
  }

  return {
    "title" : extractedTitle,
    "content": extractedContent,
    "prompt": selfExtractConfig["prompt"]
  };
}

void main() async {
  final config = {
    "site2": {
      "type": "json",
      "path_to_content": "data[0].note_list[0].desc",
      "path_to_title": "data[0].note_list[0].title",

      "default_content": "Content not found"
    },
    "prompt": "请提取内容"
  };
  String hi = "233$config";
  // Example JSON response
  final jsonResponse = r'''{"code":0,"success":true,"msg":"成功","data":[{"model_type":"note","user":{"track_duration":0,"fstatus":"none","image":"https://sns-avatar-qc.xhscdn.com/avatar/64a4fef4d53f0b000189e8ba.jpg?imageView2/2/w/120/format/jpg","followed":false,"show_red_official_verify_icon":false,"nickname":"杭州求是新理想高复","red_official_verify_type":0,"red_official_verified":false,"userid":"5e8105fb00000000010046b1","level":{"image":""},"id":"5e8105fb00000000010046b1","name":"杭州求是新理想高复","red_id":"9645696547"},"note_list":[{"user":{"name":"杭州求是新理想高复","red_id":"9645696547","show_red_official_verify_icon":false,"userid":"5e8105fb00000000010046b1","red_official_verify_type":0,"red_official_verified":false,"track_duration":0,"fstatus":"none","id":"5e8105fb00000000010046b1","image":"https://sns-avatar-qc.xhscdn.com/avatar/64a4fef4d53f0b000189e8ba.jpg?imageView2/2/w/120/format/jpg","followed":false,"nickname":"杭州求是新理想高复","level":{"image":""}},"last_update_time":1718327375,"sticky":true,"long_press_share_info":{"function_entries":[{"type":"image_download"}],"guide_audited":false,"content":"","title":"","is_star":false,"block_private_msg":false,"show_wechat_tag":false},"title":"杭州高考复读学校2024暑期招生中！","desc":"随着高考高考成绩的公布，几家欢喜几家愁。如果说高考是人生一次宝贵的机会，高复又何尝不是人生一次宝贵的机会。对成绩不满意或者升学有困难的同学应该认真分析总结高考失利的原因，再根据自身情况做出选择。在这里分享选择高考补习学校的攻略，希望对大家有所帮助。\n\t\n✅选择适合自己的补习班\n\t\n在选择高复学校时，不要盲目跟风，要根据自己的实际情况选择适合自己的班级。可以从以下方面考虑：\n\t\n1.教学质量：可以通过咨询老师、了解班级的优势和弱点等方面来了解补习班的教学质量。\n\t\n2.师资力量：高复学校的师资力量是非常重要的，优秀的老师可以帮助学生更好地掌握知识点。\n\t\n3.班级规模：班级规模不宜太大，过大的班级容易导致老师无法关注到每个学生的学习情况。\n\t\n✅合理安排学习时间\n\t\n1.制定学习计划：可以根据自己的学习进度和补习班的教学进度，制定一份详细的高复学习计划，明确每天要完成的任务。\n\t\n2.合理安排时间：要根据自己的实际情况，合理安排学习时间，不要过于疲劳，也不要浪费时间。\n\t\n3.合理安排休息时间：适当的休息可以帮助恢复精力，提高学习效率，因此要合理安排休息时间。\n\t\n✅注重做题练习\n\t\n1.注重基础知识：高考的考点很多都是基础知识，因此要注重基础知识的学习和掌握。\n\t\n2.多做模拟题：模拟题是考察学生综合能力的重要方式，因此要多做模拟题，提高解题能力。\n\t\n3.总结解题方法：在做题的过程中，要总结解题方法，找到自己的弱点，加强练习。\n\t\n✅重视课后作业\n\t\n1.及时完成：要及时完成课后作业，不要拖延。\n\t\n2.认真检查：完成作业后，要认真检查，找出错误并及时纠正。\n\t\n3.向老师请教：在完成作业的过程中，遇到难题可以向老师请教，及时解决问题。\n\t\n✅注意保持好心态\n\t\n高考是一场长跑，需要大家保持好心态，不要轻易放弃。\n\t\n1.积极心态：要积极面对高考，相信自己能够取得好成绩。\n\t\n2.不要过于焦虑：焦虑会影响学习效果，因此不要过于焦虑。\n\t\n3.保持健康：要保持健康的身体，合理饮食、适当运动，保持好心态。\n\t\n宝子们，选择高复学校的时候要擦亮眼睛哦！\n\t\n👉杭州求是新理想高复是你不错的选择！\n\t\n#高考复读[话题]#  #高三复读[话题]#  #复读生[话题]#  #高考[话题]#  #复读[话题]#  #升学[话题]# #2025高考倒计时[话题]#","ats":[],"images_list":[{"fileid":"spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0","width":1080,"index":0,"longitude":0,"latitude":0,"need_load_original_image":false,"scale_to_large":4,"height":1440,"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/1080/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","url_multi_level":{"low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"trace_id":"spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0"},{"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/1440/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","index":0,"longitude":0,"trace_id":"spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60","need_load_original_image":false,"fileid":"spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60","height":1440,"width":1080,"url_multi_level":{"high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdk0uju0005nk10ntg8hlhjb62m60?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"latitude":0,"scale_to_large":4},{"fileid":"spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8","width":1080,"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_multi_level":{"low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"longitude":0,"need_load_original_image":false,"scale_to_large":4,"height":1440,"url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/1440/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","index":0,"latitude":0,"trace_id":"spectrum/1000g0k02pdvdu56k80005nk10ntg8hlhfgp8bi8"},{"trace_id":"spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50","need_load_original_image":false,"scale_to_large":4,"width":1080,"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/1440/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","longitude":0,"latitude":0,"fileid":"spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50","height":1440,"url_multi_level":{"low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdve658k60005nk10ntg8hlhmur2g50?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"index":0},{"url_multi_level":{"low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"index":0,"longitude":0,"need_load_original_image":false,"height":1440,"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/1440/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","scale_to_large":4,"fileid":"spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8","width":1080,"latitude":0,"trace_id":"spectrum/1000g0k02pdveqbck40005nk10ntg8hlhng52cd8"},{"width":1080,"url":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","url_size_large":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/1440/format/reif/q/90","original":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/5000/h/5000/format/reif/q/99&redImage/frame/0","url_multi_level":{"high":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","low":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0","medium":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8?imageView2/2/w/540/format/jpg/q/75%7CimageMogr2/strip&redImage/frame/0"},"index":0,"fileid":"spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8","height":1440,"need_load_original_image":false,"longitude":0,"trace_id":"spectrum/1000g0k02pdvf1fqk80005nk10ntg8hlhj9nnoa8","latitude":0,"scale_to_large":4}],"cooperate_binds":[],"countdown":0,"api_upgrade":1,"enable_brand_lottery":false,"liked_count":236,"seeded_count":0,"share_info":{"show_wechat_tag":false,"guide_audited":true,"title":"杭州高考复读学校2024暑期招生中","block_private_msg":false,"link":"https://www.xiaohongshu.com/discovery/item/64abd7700000000031008ad8?app_platform=ios&app_version=8.45&share_from_user_hidden=true&xsec_source=app_share&type=normal&xsec_token=CBkm3_DTD8DxHN7xgfJnbAj_jQKX5N1f3wT6aTdAPASJY=&author_share=1","is_star":false,"function_entries":[{"type":"generate_image"},{"type":"copy_link"},{"type":"dislike"},{"type":"report"}],"content":"随着高考高考成绩的公布，几家欢喜几家愁。如果说高考是人生一次宝贵的机会，高复又何尝不是人生一次宝贵的机会。对成绩不满意或","image":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/360/format/jpg/q/75"},"enable_fls_bridge_cards":true,"goods_info":{},"use_water_color":false,"widgets_context":"{\"origin_video_key\":\"\",\"flags\":{},\"author_id\":\"5e8105fb00000000010046b1\",\"author_name\":\"杭州求是新理想高复\",\"q_task_id\":\"\",\"video_rec_bar_info\":\"\"}","enable_co_produce":false,"time":1688983408,"ad":{"hiding_native_widget":0,"type":"","title":"","link":"","bg_color":"","track_id":"adscpcn_383f7828-4422-11ef-8c7e-52540046b618#tracking@2didnottmdq82qaje71g4","is_tracking":false,"id":"383f7828-4422-11ef-8c7e-52540046b618","ads_id":"","track_url":"csSRzDIh8H/9MnmoptESPQx1U3HBiLJzExhGnyi4YoSM5XexTBi2ZqSxE+kGEbZhmHSUrT6CRMTEKtHQ+xl//8/Vhn/edeMV1o6wrHJYDtUQJL85d5QVLJr+EqVia5ovUyY0RRPg6PvVnHwCFm8pAzSYiATVpitMyY3oITE+4RFz0/7YMQ9tLRHbnoWmG4FS84Tf4frLD7kR9s43q3GzVy/xeLICcjTqr9QGLgmpws6VLk0Bn7Rz457rxIS2CnX11IE5BCloY3UODe24lkgw7b+IGGDwEarCfryI69hazuHGk/x/+ZknfA65pqfTRXI4","tag":"","second_jump_style":""},"head_tags":[],"need_next_step":false,"has_related_goods":true,"enable_fls_related_cards":false,"privacy":{"nick_names":"","type":0,"show_tips":false},"has_co_produce":false,"id":"64abd7700000000031008ad8","seeded":false,"mini_program_info":{"title":"@杭州求是新理想高复 发了一篇笔记，快点来看吧！","desc":"随着高考高考成绩的公布，几家欢喜几家愁。如果说高考是人生一次宝贵的机会，高复又何尝不是人生一次宝贵的机会。对成绩不满意或","webpage_url":"https://www.xiaohongshu.com/discovery/item/64abd7700000000031008ad8?xsec_source=app_share&xsec_token=CBkm3_DTD8DxHN7xgfJnbAj_jQKX5N1f3wT6aTdAPASJY=","thumb":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75","share_title":"@杭州求是新理想高复 发了一篇笔记，快点来看吧！","user_name":"gh_52be748ce5b7","path":"pages/main/home/index?redirect_path=%2Fpages%2Fmain%2Fnote%2Findex%3Fxsec_source%3Dapp_share%26id%3D64abd7700000000031008ad8%26type%3Dnormal%26xsec_token%3DCBkm3_DTD8DxHN7xgfJnbAj_jQKX5N1f3wT6aTdAPASJY%3D"},"view_count":0,"topics":[{"name":"高考复读","image":"http://ci.xiaohongshu.com/fd75707a-37f8-45ad-b7a7-0feaf36e9cad@r_120w_120h.jpg","link":"xhsdiscover://topic/v2/5d08938b1daca10001c47db2?page_source=note_feed.click_new_big","activity_online":false,"style":0,"discuss_num":0,"business_type":0,"id":"5d08938b000000000e00aac1"}],"widgets_groups":[["guos_test","note_next_step","second_jump_bar","cooperate_binds","note_collection","rec_next_infos","image_stickers","image_filters","product_review","related_search","cooperate_comment_component","image_goods_cards","ads_goods_cards","ads_comment_component","goods_card_v2","image_template","buyable_goods_card_v2","ads_engage_bar","challenge_card","cooperate_engage_bar","guide_post","pgy_comment_component","pgy_engage_bar","bar_below_image","aigc_collection","co_produce","widgets_ndb","next_note_guide","pgy_bbc_exp","async_group","super_activity","widgets_enhance"],["guos_test","vote_stickers","bullet_comment_lead","note_search_box","interact_pk","interact_vote","guide_heuristic","share_to_msg","follow_guide","note_share_prompt_v1","sync_group","group_share","share_guide_bubble","widgets_share"]],"media_save_config":{"disable_save":false,"disable_watermark":false,"disable_weibo_cover":false},"collected":false,"collected_count":120,"comments_count":111,"qq_mini_program_info":{"user_name":"gh_66c53d495417","path":"pages/main/note/index?xsec_source=app_share&id=64abd7700000000031008ad8&type=normal&xsec_token=CBkm3_DTD8DxHN7xgfJnbAj_jQKX5N1f3wT6aTdAPASJY=","title":"@杭州求是新理想高复 发了一篇超赞的笔记，快点来看！","desc":"随着高考高考成绩的公布，几家欢喜几家愁。如果说高考是人生一次宝贵的机会，高复又何尝不是人生一次宝贵的机会。对成绩不满意或","webpage_url":"https://www.xiaohongshu.com/discovery/item/64abd7700000000031008ad8?xsec_source=app_share&xsec_token=CBkm3_DTD8DxHN7xgfJnbAj_jQKX5N1f3wT6aTdAPASJY=","thumb":"http://sns-img-hw.xhscdn.com/spectrum/1000g0k02pdvd1pck80005nk10ntg8hlhn5iref0?imageView2/2/w/540/format/jpg/q/75","share_title":"@杭州求是新理想高复 发了一篇超赞的笔记，快点来看！"},"foot_tags":[],"liked":false,"in_censor":false,"share_code_flag":0,"has_music":false,"need_product_review":false,"liked_users":[],"model_type":"note","hash_tag":[{"name":"高考复读","type":"topic","link":"xhsdiscover://topic/v2/5d08938b1daca10001c47db2?page_source=note_feed.click_new_big&topic_name=%E9%AB%98%E8%80%83%E5%A4%8D%E8%AF%BB&source=normal&pre_source=explore_feed%26homefeed_recommend","record_count":0,"current_score":0,"id":"5d08938b000000000e00aac1","record_unit":"","bizId":"","tag_hint":"","record_emoji":""},{"name":"高三复读","type":"topic","bizId":"","tag_hint":"","id":"5d45acf0000000000d034e72","link":"xhsdiscover://topic/v2/5d45acf04a4120000112cefa?page_source=note_feed.click_new_big&topic_name=%E9%AB%98%E4%B8%89%E5%A4%8D%E8%AF%BB&source=normal&pre_source=explore_feed%26homefeed_recommend","record_emoji":"","record_count":0,"record_unit":"","current_score":0},{"type":"topic","link":"xhsdiscover://topic/v2/5ce62621847f3e00016229a1?page_source=note_feed.click_new_big&topic_name=%E5%A4%8D%E8%AF%BB%E7%94%9F&source=normal&pre_source=explore_feed%26homefeed_recommend","record_emoji":"","tag_hint":"","current_score":0,"bizId":"","id":"5ce62621000000000d039ad8","name":"复读生","record_count":0,"record_unit":""},{"link":"xhsdiscover://topic/v2/629ec4cb530abe0001485709?page_source=note_feed.click_new_big&topic_name=%E9%AB%98%E8%80%83&source=normal&pre_source=explore_feed%26homefeed_recommend","record_emoji":"","record_count":0,"current_score":0,"bizId":"","id":"629ec4cb0000000001007223","type":"topic","record_unit":"","tag_hint":"","name":"高考"},{"link":"xhsdiscover://topic/v2/5bf7a4cd4dd8c20001566b6a?page_source=note_feed.click_new_big&topic_name=%E5%A4%8D%E8%AF%BB&source=normal&pre_source=explore_feed%26homefeed_recommend","record_emoji":"","record_count":0,"current_score":0,"bizId":"","id":"5bf7a4cd1a1875000138f5eb","name":"复读","type":"topic","record_unit":"","tag_hint":""},{"name":"升学","type":"topic","record_emoji":"","record_count":0,"bizId":"","tag_hint":"","id":"5c5445f3000000000f03c56b","link":"xhsdiscover://topic/v2/5c5445f3f689490001337d85?page_source=note_feed.click_new_big&topic_name=%E5%8D%87%E5%AD%A6&source=normal&pre_source=explore_feed%26homefeed_recommend","record_unit":"","current_score":0},{"record_count":0,"current_score":0,"bizId":"","tag_hint":"","link":"xhsdiscover://topic/v2/6297acd1af149500011ef7a6?page_source=note_feed.click_new_big&topic_name=2025%E9%AB%98%E8%80%83%E5%80%92%E8%AE%A1%E6%97%B6&source=normal&pre_source=explore_feed%26homefeed_recommend","record_emoji":"","type":"topic","record_unit":"","id":"6297acd10000000001001b30","name":"2025高考倒计时"}],"shared_count":82,"may_have_red_packet":false,"type":"normal","red_envelope_note":false}],"comment_list":[],"track_id":""}]}''';

  try {
    final extractedData = await extractJSONContent(config, jsonResponse);
    print('Extracted Title: ${extractedData["title"]}');

    print('Extracted Content: ${extractedData["content"]}');
    print('Prompt: ${extractedData["prompt"]}');

  } catch (e) {
    print('Error: $e');
  }
}

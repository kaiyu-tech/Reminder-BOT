require 'test_helper'

class LinebotControllerTest < ActionDispatch::IntegrationTest

  def setup
    travel_to("2021-06-16 12:00:00 +0900")
  end

  test "register user" do
    User.destroy_all

    # successfully(Follow Event)
    assert_difference 'User.count', 1 do
      post callback_path, params: {
        "events":[
          {
            "type": "follow",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_admin",
              "type": "user"
            }
          }
        ]}, as: :json
    end
    assert_response :success

    # If it is already registered, do nothing.
    assert_no_difference 'User.count' do
      post callback_path, params: {
        "events":[
          {
            "type": "follow",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_1",
              "type": "user"
            }
          }
        ]}, as: :json
    end
    assert_response :success

    # successfully(Postback Event)
    assert_difference 'User.count', 1 do
      post callback_path, params: {
        "events":[
          {
            "type": "postback",
            "replyToken": "reply_token_dummy",
            "postback": {
              "data": "register"
            },
            "source": {
              "userId": "line_id_user_1",
              "type": "user"
            }
          }
        ]}, as: :json
    end
    assert_response :success

    # If it is already registered, do nothing.
    assert_no_difference 'User.count' do
      post callback_path, params: {
        "events":[
          {
            "type": "postback",
            "replyToken": "reply_token_dummy",
            "postback": {
              "data": "register"
            },
            "source": {
              "userId": "line_id_user_1",
              "type": "user"
            }
          }
        ]}, as: :json
    end
    assert_response :success
  end

  test "respons message" do
    # search
    assert_output("Debug: 【title1-1】\ntoday\nWed, 2021/06/16") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "きょう"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title1-2】\ntomorrow\nThu, 2021/06/17") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "あした"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "きょうあした"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "こんしゅう"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title2】\nnext week\nWed, 2021/06/23") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "らいしゅう"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17\n\n" \
                          "【title2】\nnext week\nWed, 2021/06/23") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "こんげつ"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title3】\nnext month\nFri, 2021/07/16") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "らいげつ"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: 【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "？title1"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: No results found.") {
      post callback_path, params: {
        "events":[
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "userId": "line_id_user_10",
              "type": "user"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "？ほげほげ"
            }
          }
        ]}, as: :json
    }
    assert_response :success
  end

  test "successfully send message bye" do
    assert_output("Debug: type = group, command = ばいばい") {
      post callback_path, params: {
        "events": [
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "groupId": "groupId",
              "userId": "line_id_user_10",
              "type": "group"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "ばいばい"
            }
          }
        ]}, as: :json
    }
    assert_response :success

    assert_output("Debug: type = room, command = ばいばい") {
      post callback_path, params: {
        "events": [
          {
            "type": "message",
            "replyToken": "reply_token_dummy",
            "source": {
              "roomId": "roomId",
              "userId": "line_id_user_10",
              "type": "room"
            },
            "message": {
              "type": "text",
              "id": "line_id_user_10",
              "text": "ばいばい"
            }
          }
        ]}, as: :json
    }
    assert_response :success
  end
end
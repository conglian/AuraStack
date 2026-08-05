package com.thinkup.flutter.init;

import android.text.TextUtils;

import com.thinkup.flutter.utils.MsgTools;

/**
 * Overseas secmtp stub: accept policy JSON from Flutter, no parsing / CustomController binding.
 */
public final class AdSourcePrivacyPolicyStore {

    private AdSourcePrivacyPolicyStore() {
    }

    public static void setPolicyJson(String json) {
        if (TextUtils.isEmpty(json)) {
            MsgTools.printMsg("setAdSourcePrivacyPolicy: empty");
            return;
        }
        MsgTools.printMsg("setAdSourcePrivacyPolicy: len=" + json.length());
    }
}

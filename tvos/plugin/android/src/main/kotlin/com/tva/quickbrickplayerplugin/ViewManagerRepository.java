package com.tva.quickbrickplayerplugin;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.List;

public class ViewManagerRepository {
    List<ViewManager> viewManagers = new ArrayList<>();

    public List<ViewManager> getViewManagers(ReactApplicationContext reactContext) {
        if(viewManagers.isEmpty()) {
            viewManagers.add(new TVAQuickBrickPlayerManager(reactContext));
        }
        return viewManagers;
    }
}

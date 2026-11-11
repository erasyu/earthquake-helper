package kz.earthquake.helper.widgets

import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import kz.earthquake.helper.R

class EmergencyBagRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return EmergencyBagRemoteViewsFactory(applicationContext)
    }
}

class EmergencyBagRemoteViewsFactory(
    private val context: android.content.Context
) : RemoteViewsService.RemoteViewsFactory {

    companion object {
        val itemIds = listOf(
            "first_aid",
            "flashlight",
            "radio",
            "whistle",
            "gas_mask",
            "water",
            "canned_food",
            "dry_food",
            "matches",
            "warm_clothes",
            "raincoat",
            "hygiene",
            "documents",
            "money",
            "charger"
        )

        val itemDisplayNames = mapOf(
            "first_aid" to "Аптечка первой помощи",
            "flashlight" to "Фонарик и запасные батарейки",
            "radio" to "Радиоприемник на батарейках",
            "whistle" to "Свисток",
            "gas_mask" to "Противогаз",
            "water" to "Запас воды (2 литра на человека)",
            "canned_food" to "Консервы",
            "dry_food" to "Сухое питание",
            "matches" to "Спички в водонепроницаемой упаковке",
            "warm_clothes" to "Теплые вещи",
            "raincoat" to "Дождевик",
            "hygiene" to "Средства гигиены",
            "documents" to "Документы (копии)",
            "money" to "Деньги",
            "charger" to "Зарядное устройство для телефона"
        )

        fun prefsKey(itemId: String) = "flutter.emergency_kit_$itemId"
    }

    private val items = mutableListOf<Pair<String, Boolean>>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        try {
            items.clear()
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                android.content.Context.MODE_PRIVATE
            )

            for (itemId in itemIds) {
                try {
                    val isChecked = prefs.getBoolean(prefsKey(itemId), false)
                    val displayName = itemDisplayNames[itemId] ?: itemId
                    items.add(Pair(displayName, isChecked))
                } catch (e: Exception) {
                    android.util.Log.e(
                        "EmergencyBagRemoteViewsFactory",
                        "Error reading item state: $itemId",
                        e
                    )
                    items.add(Pair(itemDisplayNames[itemId] ?: itemId, false))
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("EmergencyBagRemoteViewsFactory", "Error in onDataSetChanged", e)
            items.clear()
            for (itemId in itemIds) {
                items.add(Pair(itemDisplayNames[itemId] ?: itemId, false))
            }
        }
    }

    override fun onDestroy() {
        items.clear()
    }

    override fun getCount(): Int = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val remoteViews = RemoteViews(context.packageName, R.layout.widget_emergency_bag_item)

        try {
            if (position < 0 || position >= items.size) {
                remoteViews.setTextViewText(R.id.item_text, "")
                return remoteViews
            }

            val item = items[position]
            val displayName = if (item.first.length > 25) {
                item.first.substring(0, 22) + "..."
            } else {
                item.first
            }

            remoteViews.setTextViewText(
                R.id.item_text,
                if (item.second) "✓ $displayName" else "○ $displayName"
            )

            remoteViews.setTextColor(
                R.id.item_text,
                if (item.second) 0xFF4CAF50.toInt() else 0xFF424242.toInt()
            )

            val fillInIntent = Intent().apply {
                putExtra("item_index", position)
                putExtra("item_id", itemIds[position])
            }
            remoteViews.setOnClickFillInIntent(R.id.item_container, fillInIntent)
        } catch (e: Exception) {
            android.util.Log.e(
                "EmergencyBagRemoteViewsFactory",
                "Error in getViewAt for position $position",
                e
            )
            remoteViews.setTextViewText(R.id.item_text, "")
        }

        return remoteViews
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long =
        if (position >= 0 && position < items.size) position.toLong() else -1L

    override fun hasStableIds(): Boolean = true
}

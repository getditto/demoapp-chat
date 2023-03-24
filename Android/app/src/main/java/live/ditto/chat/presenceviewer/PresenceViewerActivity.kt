package live.ditto.chat.presenceviewer

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import live.ditto.dittopresenceviewer.PresenceViewModel
import live.ditto.dittopresenceviewer.PresenceViewerFragment
import androidx.activity.viewModels
import live.ditto.chat.DittoHandler.Companion.ditto
import live.ditto.chat.R
import live.ditto.chat.databinding.ActivityPresenceViewerBinding


class PresenceViewerActivity : AppCompatActivity() {

    private val presenceViewModel: PresenceViewModel by viewModels()
    private lateinit var binding: ActivityPresenceViewerBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityPresenceViewerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        if (savedInstanceState == null) {
            if (ditto == null) {
                finish()
                return
            }
            presenceViewModel.ditto = ditto

            println("hello from Activity 👋🏽")
            supportFragmentManager.beginTransaction()
                .replace(R.id.container, PresenceViewerFragment.newInstance())
                .commitNow()
        }
    }
}

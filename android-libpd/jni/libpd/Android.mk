LOCAL_PATH := $(call my-dir)

VORBIS_SRC_PATH		:= pure-data/extra/oggread~/libvorbis-1.3.2/
OGG_SRC_PATH		:= pure-data/extra/oggread~/libogg-1.3.0/
CYCLONE_SRC_PATH	:= pure-data/extra/cyclone/
HAMMER_SRC_PATH		:= pure-data/extra/cyclone/hammer/
SHADOW_SRC_PATH		:= pure-data/extra/cyclone/shadow/
SICKLE_SRC_PATH		:= pure-data/extra/cyclone/sickle/

# Build main library.

include $(CLEAR_VARS)
LOCAL_MODULE := pdnative
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src \
	$(LOCAL_PATH)/libpd_wrapper \
	$(LOCAL_PATH)/${OGG_SRC_PATH}include \
	$(LOCAL_PATH)/${VORBIS_SRC_PATH}include \
	$(LOCAL_PATH)/${HAMMER_SRC_PATH} \
	$(LOCAL_PATH)/${SHADOW_SRC_PATH} \
	$(LOCAL_PATH)/${SICKLE_SRC_PATH} \
	$(LOCAL_PATH)/${CYCLONE_SRC_PATH}shared \
	$(LOCAL_PATH)/${CYCLONE_SRC_PATH}common \
	$(LOCAL_PATH)/${CYCLONE_SRC_PATH}shared/unstable \


# -DUSEAPI_ALSA 
LOCAL_CFLAGS := -DPD -DHAVE_UNISTD_H -DHAVE_LIBDL \
			-Wno-int-to-pointer-cast -Wno-pointer-to-int-cast
LOCAL_LDLIBS := -ldl -llog
LOCAL_SRC_FILES := \
	pure-data/src/d_arithmetic.c pure-data/src/d_array.c pure-data/src/d_ctl.c \
	pure-data/src/d_dac.c pure-data/src/d_delay.c pure-data/src/d_fft.c \
	pure-data/src/d_fft_mayer.c pure-data/src/d_fftroutine.c \
	pure-data/src/d_filter.c pure-data/src/d_global.c pure-data/src/d_math.c \
	pure-data/src/d_misc.c pure-data/src/d_osc.c pure-data/src/d_resample.c \
	pure-data/src/d_soundfile.c pure-data/src/d_ugen.c \
	pure-data/src/g_all_guis.c pure-data/src/g_array.c pure-data/src/g_bang.c \
	pure-data/src/g_canvas.c pure-data/src/g_editor.c pure-data/src/g_graph.c \
	pure-data/src/g_guiconnect.c pure-data/src/g_hdial.c \
	pure-data/src/g_hslider.c pure-data/src/g_io.c pure-data/src/g_mycanvas.c \
	pure-data/src/g_numbox.c pure-data/src/g_readwrite.c \
	pure-data/src/g_rtext.c pure-data/src/g_scalar.c pure-data/src/g_template.c \
	pure-data/src/g_text.c pure-data/src/g_toggle.c pure-data/src/g_traversal.c \
	pure-data/src/g_vdial.c pure-data/src/g_vslider.c pure-data/src/g_vumeter.c \
	pure-data/src/m_atom.c pure-data/src/m_binbuf.c pure-data/src/m_class.c \
	pure-data/src/m_conf.c pure-data/src/m_glob.c pure-data/src/m_memory.c \
	pure-data/src/m_obj.c pure-data/src/m_pd.c pure-data/src/m_sched.c \
	pure-data/src/s_audio.c pure-data/src/s_audio_dummy.c \
	pure-data/src/s_file.c pure-data/src/s_inter.c \
	pure-data/src/s_loader.c pure-data/src/s_main.c pure-data/src/s_path.c \
	pure-data/src/s_print.c pure-data/src/s_utf8.c pure-data/src/x_acoustics.c \
	pure-data/src/x_arithmetic.c pure-data/src/x_connective.c \
	pure-data/src/x_gui.c pure-data/src/x_list.c pure-data/src/x_midi.c \
	pure-data/src/x_misc.c pure-data/src/x_net.c pure-data/src/x_qlist.c \
	pure-data/src/x_time.c pure-data/src/x_interface.c \
	libpd_wrapper/s_libpdmidi.c libpd_wrapper/x_libpdreceive.c \
	libpd_wrapper/z_libpd.c libpd_wrapper/z_jni.c \
	pure-data/extra/oggread~/oggread~.c \
	${OGG_SRC_PATH}src/framing.c \
	${OGG_SRC_PATH}src/bitwise.c \
	${VORBIS_SRC_PATH}lib/mdct.c \
	${VORBIS_SRC_PATH}lib/smallft.c \
	${VORBIS_SRC_PATH}lib/block.c \
	${VORBIS_SRC_PATH}lib/envelope.c \
	${VORBIS_SRC_PATH}lib/window.c \
	${VORBIS_SRC_PATH}lib/lsp.c \
	${VORBIS_SRC_PATH}lib/lpc.c \
	${VORBIS_SRC_PATH}lib/analysis.c \
	${VORBIS_SRC_PATH}lib/synthesis.c \
	${VORBIS_SRC_PATH}lib/psy.c \
	${VORBIS_SRC_PATH}lib/info.c \
	${VORBIS_SRC_PATH}lib/floor1.c \
	${VORBIS_SRC_PATH}lib/floor0.c \
	${VORBIS_SRC_PATH}lib/res0.c \
	${VORBIS_SRC_PATH}lib/mapping0.c \
	${VORBIS_SRC_PATH}lib/registry.c \
	${VORBIS_SRC_PATH}lib/codebook.c \
	${VORBIS_SRC_PATH}lib/sharedbook.c \
	${VORBIS_SRC_PATH}lib/lookup.c \
	${VORBIS_SRC_PATH}lib/bitrate.c \
	${VORBIS_SRC_PATH}lib/vorbisfile.c \
	${SHADOW_SRC_PATH}cyclone.c \
	${SHADOW_SRC_PATH}dummies.c \
	${SHADOW_SRC_PATH}maxmode.c \
	${SHADOW_SRC_PATH}nettles.c \
	${SICKLE_SRC_PATH}abs.c \
	${SICKLE_SRC_PATH}acos.c \
	${SICKLE_SRC_PATH}acosh.c \
	${SICKLE_SRC_PATH}allpass.c \
	${SICKLE_SRC_PATH}allsickles.c \
	${SICKLE_SRC_PATH}asin.c \
	${SICKLE_SRC_PATH}asinh.c \
	${SICKLE_SRC_PATH}atan.c \
	${SICKLE_SRC_PATH}atan2.c \
	${SICKLE_SRC_PATH}atanh.c \
	${SICKLE_SRC_PATH}average.c \
	${SICKLE_SRC_PATH}avg.c \
	${SICKLE_SRC_PATH}bitand.c \
	${SICKLE_SRC_PATH}bitnot.c \
	${SICKLE_SRC_PATH}bitor.c \
	${SICKLE_SRC_PATH}bitshift.c \
	${SICKLE_SRC_PATH}bitxor.c \
	${SICKLE_SRC_PATH}buffir.c \
	${SICKLE_SRC_PATH}capture.c \
	${SICKLE_SRC_PATH}cartopol.c \
	${SICKLE_SRC_PATH}change.c \
	${SICKLE_SRC_PATH}click.c \
	${SICKLE_SRC_PATH}Clip.c \
	${SICKLE_SRC_PATH}comb.c \
	${SICKLE_SRC_PATH}cosh.c \
	${SICKLE_SRC_PATH}cosx.c \
	${SICKLE_SRC_PATH}count.c \
	${SICKLE_SRC_PATH}curve.c \
	${SICKLE_SRC_PATH}cycle.c \
	${SICKLE_SRC_PATH}delay.c \
	${SICKLE_SRC_PATH}delta.c \
	${SICKLE_SRC_PATH}deltaclip.c \
	${SICKLE_SRC_PATH}edge.c \
	${SICKLE_SRC_PATH}frameaccum.c \
	${SICKLE_SRC_PATH}framedelta.c \
	${SICKLE_SRC_PATH}index.c \
	${SICKLE_SRC_PATH}kink.c \
	${SICKLE_SRC_PATH}Line.c \
	${SICKLE_SRC_PATH}linedrive.c \
	${SICKLE_SRC_PATH}log.c \
	${SICKLE_SRC_PATH}lookup.c \
	${SICKLE_SRC_PATH}lores.c \
	${SICKLE_SRC_PATH}matrix.c \
	${SICKLE_SRC_PATH}maximum.c \
	${SICKLE_SRC_PATH}minimum.c \
	${SICKLE_SRC_PATH}minmax.c \
	${SICKLE_SRC_PATH}mstosamps.c \
	${SICKLE_SRC_PATH}onepole.c \
	${SICKLE_SRC_PATH}overdrive.c \
	${SICKLE_SRC_PATH}peakamp.c \
	${SICKLE_SRC_PATH}peek.c \
	${SICKLE_SRC_PATH}phasewrap.c \
	${SICKLE_SRC_PATH}pink.c \
	${SICKLE_SRC_PATH}play.c \
	${SICKLE_SRC_PATH}poke.c \
	${SICKLE_SRC_PATH}poltocar.c \
	${SICKLE_SRC_PATH}pong.c \
	${SICKLE_SRC_PATH}pow.c \
	${SICKLE_SRC_PATH}rampsmooth.c \
	${SICKLE_SRC_PATH}rand.c \
	${SICKLE_SRC_PATH}record.c \
	${SICKLE_SRC_PATH}reson.c \
	${SICKLE_SRC_PATH}sah.c \
	${SICKLE_SRC_PATH}sampstoms.c \
	${SICKLE_SRC_PATH}Scope.c \
	${SICKLE_SRC_PATH}sickle.c \
	${SICKLE_SRC_PATH}sinh.c \
	${SICKLE_SRC_PATH}sinx.c \
	${SICKLE_SRC_PATH}slide.c \
	${SICKLE_SRC_PATH}Snapshot.c \
	${SICKLE_SRC_PATH}spike.c \
	${SICKLE_SRC_PATH}svf.c \
	${SICKLE_SRC_PATH}tanh.c \
	${SICKLE_SRC_PATH}tanx.c \
	${SICKLE_SRC_PATH}train.c \
	${SICKLE_SRC_PATH}trapezoid.c \
	${SICKLE_SRC_PATH}triangle.c \
	${SICKLE_SRC_PATH}vectral.c \
	${SICKLE_SRC_PATH}wave.c \
	${SICKLE_SRC_PATH}zerox.c \
	${HAMMER_SRC_PATH}accum.c \
	${HAMMER_SRC_PATH}acos.c \
	${HAMMER_SRC_PATH}active.c \
	${HAMMER_SRC_PATH}allhammers.c \
	${HAMMER_SRC_PATH}anal.c \
	${HAMMER_SRC_PATH}Append.c \
	${HAMMER_SRC_PATH}asin.c \
	${HAMMER_SRC_PATH}bangbang.c \
	${HAMMER_SRC_PATH}bondo.c \
	${HAMMER_SRC_PATH}Borax.c \
	${HAMMER_SRC_PATH}Bucket.c \
	${HAMMER_SRC_PATH}buddy.c \
	${HAMMER_SRC_PATH}capture.c \
	${HAMMER_SRC_PATH}cartopol.c \
	${HAMMER_SRC_PATH}Clip.c \
	${HAMMER_SRC_PATH}coll.c \
	${HAMMER_SRC_PATH}comment.c \
	${HAMMER_SRC_PATH}cosh.c \
	${HAMMER_SRC_PATH}counter.c \
	${HAMMER_SRC_PATH}cycle.c \
	${HAMMER_SRC_PATH}decide.c \
	${HAMMER_SRC_PATH}Decode.c \
	${HAMMER_SRC_PATH}drunk.c \
	${HAMMER_SRC_PATH}flush.c \
	${HAMMER_SRC_PATH}forward.c \
	${HAMMER_SRC_PATH}fromsymbol.c \
	${HAMMER_SRC_PATH}funbuff.c \
	${HAMMER_SRC_PATH}funnel.c \
	${HAMMER_SRC_PATH}gate.c \
	${HAMMER_SRC_PATH}grab.c \
	${HAMMER_SRC_PATH}hammer.c \
	${HAMMER_SRC_PATH}Histo.c \
	${HAMMER_SRC_PATH}iter.c \
	${HAMMER_SRC_PATH}match.c \
	${HAMMER_SRC_PATH}maximum.c \
	${HAMMER_SRC_PATH}mean.c \
	${HAMMER_SRC_PATH}midiflush.c \
	${HAMMER_SRC_PATH}midiformat.c \
	${HAMMER_SRC_PATH}midiparse.c \
	${HAMMER_SRC_PATH}minimum.c \
	${HAMMER_SRC_PATH}mousefilter.c \
	${HAMMER_SRC_PATH}MouseState.c \
	${HAMMER_SRC_PATH}mtr.c \
	${HAMMER_SRC_PATH}next.c \
	${HAMMER_SRC_PATH}offer.c \
	${HAMMER_SRC_PATH}onebang.c \
	${HAMMER_SRC_PATH}past.c \
	${HAMMER_SRC_PATH}Peak.c \
	${HAMMER_SRC_PATH}poltocar.c \
	${HAMMER_SRC_PATH}prepend.c \
	${HAMMER_SRC_PATH}prob.c \
	${HAMMER_SRC_PATH}pv.c \
	${HAMMER_SRC_PATH}seq.c \
	${HAMMER_SRC_PATH}sinh.c \
	${HAMMER_SRC_PATH}speedlim.c \
	${HAMMER_SRC_PATH}spell.c \
	${HAMMER_SRC_PATH}split.c \
	${HAMMER_SRC_PATH}spray.c \
	${HAMMER_SRC_PATH}sprintf.c \
	${HAMMER_SRC_PATH}substitute.c \
	${HAMMER_SRC_PATH}sustain.c \
	${HAMMER_SRC_PATH}switch.c \
	${HAMMER_SRC_PATH}Table.c \
	${HAMMER_SRC_PATH}tanh.c \
	${HAMMER_SRC_PATH}testmess.c \
	${HAMMER_SRC_PATH}thresh.c \
	${HAMMER_SRC_PATH}TogEdge.c \
	${HAMMER_SRC_PATH}tosymbol.c \
	${HAMMER_SRC_PATH}Trough.c \
	${HAMMER_SRC_PATH}universal.c \
	${HAMMER_SRC_PATH}urn.c \
	${HAMMER_SRC_PATH}Uzi.c \
	${HAMMER_SRC_PATH}xbendin.c \
	${HAMMER_SRC_PATH}xbendin2.c \
	${HAMMER_SRC_PATH}xbendout.c \
	${HAMMER_SRC_PATH}xbendout2.c \
	${HAMMER_SRC_PATH}xnotein.c \
	${HAMMER_SRC_PATH}xnoteout.c \
	${HAMMER_SRC_PATH}zl.c \
	${CYCLONE_SRC_PATH}shared/common/binport.c \
	${CYCLONE_SRC_PATH}shared/common/clc.c \
	${CYCLONE_SRC_PATH}shared/common/dict.c \
	${CYCLONE_SRC_PATH}shared/common/fitter.c \
	${CYCLONE_SRC_PATH}shared/common/grow.c \
	${CYCLONE_SRC_PATH}shared/common/lex.c \
	${CYCLONE_SRC_PATH}shared/common/loud.c \
	${CYCLONE_SRC_PATH}shared/common/messtree.c \
	${CYCLONE_SRC_PATH}shared/common/mifi.c \
	${CYCLONE_SRC_PATH}shared/common/os.c \
	${CYCLONE_SRC_PATH}shared/common/patchvalue.c \
	${CYCLONE_SRC_PATH}shared/common/port.c \
	${CYCLONE_SRC_PATH}shared/common/props.c \
	${CYCLONE_SRC_PATH}shared/common/qtree.c \
	${CYCLONE_SRC_PATH}shared/common/rand.c \
	${CYCLONE_SRC_PATH}shared/common/vefl.c \
	${CYCLONE_SRC_PATH}shared/hammer/file.c \
	${CYCLONE_SRC_PATH}shared/hammer/gui.c \
	${CYCLONE_SRC_PATH}shared/hammer/tree.c \
	${CYCLONE_SRC_PATH}shared/shared.c \
	${CYCLONE_SRC_PATH}shared/sickle/arsic.c \
	${CYCLONE_SRC_PATH}shared/sickle/sic.c \
	${CYCLONE_SRC_PATH}shared/toxy/plusbob.c \
	${CYCLONE_SRC_PATH}shared/toxy/scriptlet.c \
	${CYCLONE_SRC_PATH}shared/unstable/forky.c \
	${CYCLONE_SRC_PATH}shared/unstable/fragile.c \
	${CYCLONE_SRC_PATH}shared/unstable/fringe.c \
	${CYCLONE_SRC_PATH}shared/unstable/loader.c \


include $(BUILD_SHARED_LIBRARY)

# Build libchoice.so.

include $(CLEAR_VARS)

LOCAL_MODULE := choice
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/choice/choice.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


# Build libbonk~.so

include $(CLEAR_VARS)

LOCAL_MODULE := bonk~
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/bonk~/bonk~.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


# Build liblrshift~.so

include $(CLEAR_VARS)

LOCAL_MODULE := lrshift~
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/lrshift~/lrshift~.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


#Build libfiddle~.so

include $(CLEAR_VARS)

LOCAL_MODULE := fiddle~
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/fiddle~/fiddle~.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


#Build libsigmund~.so

include $(CLEAR_VARS)

LOCAL_MODULE := sigmund~
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/sigmund~/sigmund~.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


#Build libpique.so

include $(CLEAR_VARS)

LOCAL_MODULE := pique
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/pique/pique.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


#Build libloop~.so

include $(CLEAR_VARS)

LOCAL_MODULE := loop~
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/loop~/loop~.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


# Build libexpr~.so

include $(CLEAR_VARS)

LOCAL_MODULE := expr
LOCAL_C_INCLUDES := $(LOCAL_PATH)/pure-data/src
LOCAL_CFLAGS := -DPD
LOCAL_SRC_FILES := pure-data/extra/expr~/vexp.c \
          pure-data/extra/expr~/vexp_fun.c pure-data/extra/expr~/vexp_if.c
LOCAL_SHARED_LIBRARIES := pdnative

include $(BUILD_SHARED_LIBRARY)


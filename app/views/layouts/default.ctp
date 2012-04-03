<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <?= $this->Html->charset(); ?>
        <title>
            Wingolf
            <?php
            /*
              __('Wingolf');
              echo Sanitize::html($title_for_layout);
             */
            ?>
        </title>
        <?php
        echo $this->Html->meta('icon');
        echo $this->Html->meta('description', '');
        echo $this->Html->meta('keywords', '');
        echo $this->Html->css('jquery.fancybox-1.3.4');
        echo $this->Html->css('global');
        echo '
            <script type="text/javascript">
                var webroot = "' . Configure::read('App.base') . '";
            </script>
        ';
        echo $this->Html->script('jquery-1.7.1.min');
        echo $this->Html->script('jquery.fancybox-1.3.4.pack');
        echo $this->Html->script('global');
        echo $this->Html->script('frontend');
        echo $this->Html->script('jquery.hotkeys');
        echo $scripts_for_layout;
        ?>
    </head>
    <body>
        <noscript>
        <style type="text/css">
            #header_navi{ display: block; }
        </style>
        </noscript>
        <div id="headerBg">
            <div id="header">

                <div id="header_claim">
                    <?php
                    echo $this->Html->link($this->Html->image('claim.png', array('alt' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'title' => 'Wingolf - Christlich Farbentragend Nichtschlagend')), Router::url('/', true), array('title' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'escape' => false));
                    ?>
                </div>

                <div id="header_logo">
                    <?php
                    echo $this->Html->link($this->Html->image('logo.png', array('alt' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'title' => 'Wingolf - Christlich Farbentragend Nichtschlagend')), Router::url('/', true), array('title' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'escape' => false));
                    ?>
                </div>

                <div id="header_search">
                    <?php
                    echo $this->Form->create('Suche', array('controller' => 'searches', 'action' => 'index'));

                    $searchDefault = 'Suche';
                    echo $this->Form->input('search_word', array(
                        'label' => false,
                        'id' => 'header_search_input',
                        'default' => $searchDefault,
                        'onfocus' => 'if(this.value == "' . $searchDefault . '") this.value = ""',
                        'onblur' => 'if(this.value == "") this.value = "' . $searchDefault . '"'
                    ));

                    echo $this->Form->submit('search_button.png', array(
                        'id' => 'search_button'
                    ));

                    echo '<div class="clear"></div>';

                    echo $this->Form->end();
                    ?>
                </div>

                <div id="header_navi">
                    <ul class="navi_root">
                        <li class="active"><?= $this->Html->link('Start', array('#'), array('title' => '')); ?></li>
                        <li><?= $this->Html->link('Wingolf', array('#'), array('title' => '')); ?></li>
                        <li><?= $this->Html->link('Studieren', array('#'), array('title' => '')); ?></li>
                        <li><?= $this->Html->link('Wohnen', array('#'), array('title' => '')); ?></li>
                        <li><?= $this->Html->link('Verbindungen', array('#'), array('title' => '')); ?></li>
                        <li><?= $this->Html->link('Mitglieder', array('#'), array('title' => '')); ?></li>
                    </ul>
                    <div class="clear"></div>
                </div>

            </div>
        </div>

        <div id="contentBgLayer1">
            <div id="contentBgLayer2">
                <div id="contentBgLayer3">
                    <div id="content_wrapper">

                        <div id="breadcrumb">
                            <ul>
                                <li><?= $this->Html->link('Wingolf.org', array('#'), array('title' => '')); ?>&nbsp;&nbsp;>&nbsp;&nbsp;</li>
                                <li><?= $this->Html->link('Mitglieder', array('#'), array('title' => '')); ?>&nbsp;&nbsp;>&nbsp;&nbsp;</li>
                                <li class="active"><?= $this->Html->link('Erlanger Wingolf', array('#'), array('title' => '')); ?></li>
                            </ul>
                            <div class="clear"></div>
                        </div>

                        <?= $this->Session->flash(); ?>

                        <div id="content">
                            <?= $content_for_layout; ?>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <div id="footer">
            <div id="footer_bg"></div>
            <div id="footer_navi">
                <ul>
                    <li><?= $this->Html->link('Hilfe/Hinweise', array('#'), array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Verbesserungen', array('#'), array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Ansprechpartner', array('#'), array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Impressum', array('#'), array('title' => '')); ?></li>
                </ul>
                <div class="clear"></div>
            </div>
            <div id="footer_line"></div>
        </div>
        <?= $this->element('sql_dump'); ?>
    </body>
</html>